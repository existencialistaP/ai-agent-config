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

@test "install publica as arvores canonicas em ~/.omp/agent" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ "$(readlink -f "$HOME/.omp/agent/AGENTS.md")" = "$(readlink -f "$REPO/omp/AGENTS.md")" ]
    [ "$(readlink -f "$HOME/.omp/agent/APPEND_SYSTEM.md")" = "$(readlink -f "$REPO/omp/APPEND_SYSTEM.md")" ]
    [ "$(readlink -f "$HOME/.omp/agent/config.yml")" = "$(readlink -f "$REPO/omp/config.yml")" ]
    [ "$(readlink -f "$HOME/.omp/agent/mcp.json")" = "$(readlink -f "$REPO/omp/mcp.json")" ]
    [ "$(readlink -f "$HOME/.omp/agent/skills")" = "$(readlink -f "$REPO/skills")" ]
    [ "$(readlink -f "$HOME/.omp/agent/agents")" = "$(readlink -f "$REPO/agents")" ]
    [ "$(readlink -f "$HOME/.omp/agent/commands")" = "$(readlink -f "$REPO/commands")" ]
    [ "$(readlink -f "$HOME/.omp/agent/skills-janitor")" = "$(readlink -f "$REPO/skills-janitor")" ]

    [ "$(find -L "$HOME/.omp/agent/commands" -maxdepth 1 -type f | wc -l)" -eq 21 ]
    [ "$(find -L "$HOME/.omp/agent/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)" -eq "$(find -L "$REPO/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)" ]
    [ ! -e "$HOME/.omp/agent/commands/context-update.md" ]
    [ ! -e "$HOME/.config/opencode" ]
}

@test "conflito real vai para backup e a segunda execucao nao cria backup novo" {
    mkdir -p "$HOME/.omp/agent/commands"
    printf 'meu comando\n' >"$HOME/.omp/agent/commands/meu.md"

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

    [ -f "$HOME/.omp/marketplaces.json" ]
    [ -f "$HOME/.omp/plugins/omp-plugins.lock.json" ]

    ! grep -q '\${HOME}' "$HOME/.omp/marketplaces.json"
    grep -q "$HOME/.omp/plugins/cache/marketplaces" "$HOME/.omp/marketplaces.json"
    grep -q 'i-have-adhd' "$HOME/.omp/plugins/omp-plugins.lock.json"
}

@test "seeds nunca sobrescrevem a versao live" {
    mkdir -p "$HOME/.omp/plugins"
    printf '{"plugins":{"outro":{"version":"9.9.9"}}}\n' >"$HOME/.omp/plugins/omp-plugins.lock.json"

    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    grep -q 'outro' "$HOME/.omp/plugins/omp-plugins.lock.json"
    ! grep -q 'i-have-adhd' "$HOME/.omp/plugins/omp-plugins.lock.json"
}

@test "--dry-run nao cria diretorio, backup, copia nem link" {
    run "$REPO/install.sh" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"+ mkdir -p"* ]]
    [[ "$output" == *"+ ln -s"* ]]
    [[ "$output" == *"+ write"* ]]

    [ ! -e "$HOME/.omp" ]
    [ ! -e "$XDG_STATE_HOME" ]
}

@test "opcao desconhecida encerra com 2" {
    run "$REPO/install.sh" --nope
    [ "$status" -eq 2 ]
}

@test "install remove link legado que aponta para o repo" {
    mkdir -p "$HOME/.config/opencode"
    ln -s "$REPO/skills" "$HOME/.config/opencode/skills"

    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ ! -e "$HOME/.config/opencode/skills" ]
    [ -n "$(find "$BACKUPS" -type l -name '*opencode-skills' | head -n 1)" ]
}

@test "install preserva arquivo real no caminho legado" {
    mkdir -p "$HOME/.config/opencode"
    printf 'config propria\n' >"$HOME/.config/opencode/opencode.jsonc"

    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    [ "$(cat "$HOME/.config/opencode/opencode.jsonc")" = "config propria" ]
}

@test "doctor passa depois do install" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    run "$REPO/doctor.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"0 erro(s)"* ]]
    [[ "$output" == *"skills compartilhados: $(find -L "$REPO/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)"* ]]
    [[ "$output" == *"commands compartilhados: 21"* ]]
}

@test "doctor acusa link quebrado" {
    run "$REPO/install.sh"
    [ "$status" -eq 0 ]

    ln -sfn /caminho/que/nao/existe "$HOME/.omp/agent/skills"
    run "$REPO/doctor.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"ERRO"* ]]
    [[ "$output" == *"skills"* ]]
}
