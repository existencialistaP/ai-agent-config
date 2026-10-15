#!/usr/bin/env bats
#
# Testes de install.sh/doctor.sh em HOME descartavel. Nenhum teste usa a rede,
# o home real ou credenciais: os executaveis externos vem de tests/fakes/.

setup() {
    REPO="$BATS_TEST_DIRNAME/.."
    export HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$HOME"
    export XDG_STATE_HOME="$BATS_TEST_TMPDIR/state"
    FAKEBIN="$BATS_TEST_TMPDIR/fakebin"
    mkdir -p "$FAKEBIN"
    local f
    for f in "$REPO"/tests/fakes/*; do
        ln -s "$f" "$FAKEBIN/$(basename "$f")"
    done
    export PATH="$FAKEBIN:$PATH"
    BACKUPS="$XDG_STATE_HOME/ai-agent-config/backups"
}

@test "install publica OpenCode->repo e OMP->OpenCode" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ "$(readlink -f "$HOME/.config/opencode/opencode.jsonc")" = "$(readlink -f "$REPO/opencode/opencode.jsonc")" ]
    [ "$(readlink -f "$HOME/.config/opencode/commands")" = "$(readlink -f "$REPO/opencode/commands")" ]
    [ "$(readlink -f "$HOME/.config/opencode/skills")" = "$(readlink -f "$REPO/opencode/skills")" ]
    [ "$(readlink -f "$HOME/.config/opencode/plugins/adaptive-thinking.js")" = "$(readlink -f "$REPO/opencode/plugins/adaptive-thinking.js")" ]
    [ "$(readlink -f "$HOME/.omp/agent/commands")" = "$(readlink -f "$REPO/opencode/commands")" ]
    [ "$(readlink -f "$HOME/.omp/agent/skills")" = "$(readlink -f "$REPO/opencode/skills")" ]

    # O link do OMP aponta para o OpenCode, nao direto para o repositorio.
    [ "$(readlink "$HOME/.omp/agent/commands")" = "$HOME/.config/opencode/commands" ]
    [ "$(readlink "$HOME/.omp/agent/skills")" = "$HOME/.config/opencode/skills" ]

    [ "$(find -L "$HOME/.config/opencode/commands" -maxdepth 1 -type f | wc -l)" -eq 20 ]
    [ "$(find -L "$HOME/.config/opencode/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)" -eq 29 ]
    [ ! -e "$HOME/.omp/agent/commands/context-update.md" ]
}

@test "conflito real vai para backup e a segunda execucao nao cria backup novo" {
    mkdir -p "$HOME/.config/opencode/commands"
    printf 'meu comando\n' >"$HOME/.config/opencode/commands/meu.md"

    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    local saved
    saved=$(find "$BACKUPS" -type f -name 'meu.md' | head -n 1)
    [ -n "$saved" ]
    [ "$(cat "$saved")" = "meu comando" ]

    local before after
    before=$(find "$BACKUPS" -maxdepth 1 -mindepth 1 -type d | wc -l)
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]
    after=$(find "$BACKUPS" -maxdepth 1 -mindepth 1 -type d | wc -l)
    [ "$before" -eq "$after" ]
}

@test "seeds ausentes sao instalados com o home resolvido" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ -f "$HOME/.config/opencode/cli.json" ]
    [ -f "$HOME/.config/opencode/tui.jsonc" ]
    [ -f "$HOME/.omp/marketplaces.json" ]
    [ -f "$HOME/.omp/plugins/omp-plugins.lock.json" ]

    ! grep -q '\${HOME}' "$HOME/.omp/marketplaces.json"
    grep -q "$HOME/.omp/plugins/cache/marketplaces" "$HOME/.omp/marketplaces.json"
    grep -q 'i-have-adhd' "$HOME/.omp/plugins/omp-plugins.lock.json"
}

@test "seeds nunca sobrescrevem a versao live" {
    mkdir -p "$HOME/.config/opencode" "$HOME/.omp/plugins"
    printf '{"plugins":["herdr"]}\n' >"$HOME/.config/opencode/cli.json"
    printf '{"plugin":["herdr"]}\n' >"$HOME/.config/opencode/tui.jsonc"
    printf '{"plugins":{"outro":{"version":"9.9.9"}}}\n' >"$HOME/.omp/plugins/omp-plugins.lock.json"

    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ "$(cat "$HOME/.config/opencode/cli.json")" = '{"plugins":["herdr"]}' ]
    [ "$(cat "$HOME/.config/opencode/tui.jsonc")" = '{"plugin":["herdr"]}' ]
    grep -q 'outro' "$HOME/.omp/plugins/omp-plugins.lock.json"
    ! grep -q 'i-have-adhd' "$HOME/.omp/plugins/omp-plugins.lock.json"
}

@test "--dry-run nao cria diretorio, backup, copia nem link" {
    run "$REPO/install.sh" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"+ mkdir -p"* ]]
    [[ "$output" == *"+ ln -s"* ]]
    [[ "$output" == *"+ write"* ]]

    [ ! -e "$HOME/.config/opencode" ]
    [ ! -e "$HOME/.omp" ]
    [ ! -e "$XDG_STATE_HOME" ]
}

@test "opcao desconhecida encerra com 2" {
    run "$REPO/install.sh" --nope
    [ "$status" -eq 2 ]
}

@test "doctor passa depois do install" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    run "$REPO/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"0 erro(s)"* ]]
    [[ "$output" == *"29"* ]]
    [[ "$output" == *"20"* ]]
}

@test "doctor acusa link quebrado" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    ln -sfn /caminho/que/nao/existe "$HOME/.config/opencode/skills"
    run "$REPO/doctor.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"ERRO"* ]]
    [[ "$output" == *"skills"* ]]
}
