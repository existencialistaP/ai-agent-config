#!/usr/bin/env bash
# Publica as configuracoes deste checkout no harness OMP.
#
#   ./install.sh [--dry-run]
#
# Nunca toca em auth/state (auth.json, bancos, sessoes, contexts, caches).
# Conflitos reais sao movidos para
# ~/.local/state/ai-agent-config/backups/<timestamp>/ antes de virar link, e os
# seeds mutaveis so sao copiados quando ainda nao existem no destino.

set -euo pipefail

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
DRY_RUN=0
OMP_DIR="$HOME/.omp/agent"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ai-agent-config"
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%dT%H%M%S)"

usage() {
    cat <<'EOF'
uso: ./install.sh [--dry-run]

  --dry-run   mostra o que seria feito, sem criar diretorio, backup, copia ou link
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            printf 'install: opcao desconhecida: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

info() { printf '[install] %s\n' "$*"; }
run() {
    if [ "$DRY_RUN" = "1" ]; then
        printf '+ %s\n' "$*"
    else
        "$@"
    fi
}

# shellcheck source=mapping.sh
. "$REPO_ROOT/mapping.sh"

ensure_dir() { [ -d "$1" ] || run mkdir -p "$1"; }

backup_path() { # destino absoluto
    local dst="$1" name
    name=$(printf '%s' "${dst#"$HOME"/}" | tr '/' '-')
    run mkdir -p "$BACKUP_DIR"
    run mv "$dst" "$BACKUP_DIR/$name"
    info "backup: $dst -> $BACKUP_DIR/$name"
}

link_target() { # origem destino
    local src="$1" dst="$2" cur expect
    if [ -L "$dst" ]; then
        cur=$(readlink -f "$dst" 2>/dev/null || true)
        expect=$(readlink -f "$src" 2>/dev/null || true)
        if [ -n "$cur" ] && [ -n "$expect" ] && [ "$cur" = "$expect" ]; then
            info "link ok: $dst"
            return 0
        fi
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup_path "$dst"
    fi
    ensure_dir "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

prune_legacy_link() { # destino absoluto
    local dst="$1" raw resolved
    [ -L "$dst" ] || return 0
    raw=$(readlink "$dst" 2>/dev/null || true)
    resolved=$(readlink -f "$dst" 2>/dev/null || true)
    case "$raw $resolved" in
        *"$REPO_ROOT"*)
            backup_path "$dst"
            ;;
        *)
            info "link legado mantido (fora do repo): $dst"
            ;;
    esac
}

install_seed() { # origem destino
    local src="$1" dst="$2"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        info "seed preservado: $dst"
        return 0
    fi
    if [ "$DRY_RUN" = "1" ]; then
        printf '+ write %s (seed de %s)\n' "$dst" "$src"
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    # O placeholder ${HOME} cobre caminhos que so existem por maquina.
    sed "s|\${HOME}|$HOME|g" "$src" >"$dst"
    info "seed instalado: $dst"
}

ensure_dir "$OMP_DIR"

for dst in "${legacy_links[@]}"; do
    prune_legacy_link "$dst"
done

for entry in "${link_sources[@]}"; do
    link_target "$REPO_ROOT/${entry%%|*}" "${entry##*|}"
done

for entry in "${seed_sources[@]}"; do
    install_seed "$REPO_ROOT/${entry%%|*}" "${entry##*|}"
done

info "concluido; rode ./doctor.sh para conferir o resultado"
