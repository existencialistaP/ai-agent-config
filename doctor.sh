#!/usr/bin/env bash
# Confere a instalacao do harness: executaveis, links, contagens, paths fixos,
# gateway do sleev e integracoes opcionais.
#
# Erros estruturais (link errado/quebrado, contagem fora do esperado, path de
# usuario fixo no que vai para o Git) falham com exit 1. Ausencia de auth,
# gateway ou integracao externa gera aviso com a instrucao manual -- nada aqui
# copia credencial ou artefato gerado por outro aplicativo.

set -uo pipefail

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
CONFIG_DIR="$HOME/.config/opencode"
OMP_DIR="$HOME/.omp/agent"
EXPECTED_SKILLS=29
EXPECTED_COMMANDS=20

errors=0
warnings=0
ok() { printf '[doctor] %s\n' "$*"; }
err() {
    printf '[doctor] ERRO: %s\n' "$*" >&2
    errors=$((errors + 1))
}
warn() {
    printf '[doctor] aviso: %s\n' "$*" >&2
    warnings=$((warnings + 1))
}

# shellcheck source=mapping.sh
. "$REPO_ROOT/mapping.sh"

for cmd in opencode omp serena openwiki sleev; do
    if command -v "$cmd" >/dev/null 2>&1; then
        ok "executavel: $cmd"
    else
        warn "executavel ausente: $cmd (instale pelo perfil ai-harness do cachyos-dotfiles)"
    fi
done

check_link() { # esperado destino
    local want="$1" dst="$2" got expect
    if [ ! -L "$dst" ]; then
        err "nao e link: $dst"
        return 0
    fi
    got=$(readlink -f "$dst" 2>/dev/null || true)
    expect=$(readlink -f "$want" 2>/dev/null || true)
    if [ -n "$got" ] && [ -n "$expect" ] && [ "$got" = "$expect" ]; then
        ok "link: $dst"
    else
        err "link divergente ou quebrado: $dst -> ${got:-<vazio>} (esperado $expect)"
    fi
}

for entry in "${link_sources[@]}"; do
    check_link "$REPO_ROOT/${entry%%|*}" "${entry##*|}"
done

for entry in "${link_derived[@]}"; do
    check_link "${entry%%|*}" "${entry##*|}"
done

broken=$(find "$CONFIG_DIR" "$OMP_DIR" -xtype l 2>/dev/null | tr '\n' ' ' || true)
if [ -n "$broken" ]; then
    err "links quebrados: $broken"
fi

# Nada do que vai para o Git pode carregar o caminho do home desta maquina.
if [ -n "$HOME" ] && grep -rIlF --exclude-dir=.git "$HOME" \
    "$REPO_ROOT/opencode" "$REPO_ROOT/omp" "$REPO_ROOT/mapping.sh" 2>/dev/null | grep -q .; then
    err "referencia ao home da maquina ($HOME) no repositorio"
fi

skills=$(find -L "$CONFIG_DIR/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
commands=$(find -L "$CONFIG_DIR/commands" -maxdepth 1 -mindepth 1 -type f 2>/dev/null | wc -l)
if [ "$skills" -eq "$EXPECTED_SKILLS" ]; then
    ok "skills compartilhados: $skills"
else
    err "skills compartilhados: $skills (esperado $EXPECTED_SKILLS)"
fi
if [ "$commands" -eq "$EXPECTED_COMMANDS" ]; then
    ok "commands compartilhados: $commands"
else
    err "commands compartilhados: $commands (esperado $EXPECTED_COMMANDS)"
fi

if [ -e "$OMP_DIR/commands/context-update.md" ]; then
    err "comando orfao presente: $OMP_DIR/commands/context-update.md"
else
    ok "sem comando orfao (context-update.md)"
fi

if command -v sleev >/dev/null 2>&1; then
    if sleev gateway status 2>/dev/null | grep -q '127\.0\.0\.1:17321'; then
        ok "gateway do sleev em 127.0.0.1:17321"
    else
        warn "gateway do sleev fora de 127.0.0.1:17321: rode 'sleev setup --no-open' e, apos o login, 'sleev gateway bind --host 127.0.0.1 --port 17321 --restart'"
    fi
fi

# Integracoes geradas por Orca/herdr: opcionais e nunca versionadas.
for f in "$CONFIG_DIR/plugins/orca-opencode-status.js" \
    "$CONFIG_DIR/plugins/herdr-agent-state.js" \
    "$CONFIG_DIR/herdr-tui-session.js"; do
    [ -e "$f" ] || warn "integracao externa ausente (opcional): $f"
done

if [ -d "$HOME/.omp/plugins/cache/plugins/i-have-adhd___i-have-adhd___0.4.1" ]; then
    ok "plugin i-have-adhd@0.4.1 instalado"
else
    warn "plugin i-have-adhd@0.4.1 ausente: 'omp plugin marketplace add ayghri/i-have-adhd' e depois 'omp plugin install i-have-adhd@0.4.1'"
fi

printf '[doctor] %d erro(s), %d aviso(s)\n' "$errors" "$warnings"
[ "$errors" -eq 0 ]
