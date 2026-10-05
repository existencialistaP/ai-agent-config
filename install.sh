#!/usr/bin/env bash
set -euo pipefail

# Instala a config compartilhada apontando duas env vars para este clone.
# Rode a partir do diretório do clone:  ~/.config/opencode-sdd/install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

detect_rc() {
  case "${SHELL:-}" in
    */zsh)  echo "$HOME/.zshrc" ;;
    */bash) echo "$HOME/.bashrc" ;;
    *)      echo "$HOME/.profile" ;;
  esac
}

RC_FILE="$(detect_rc)"
BLOCK_START="# >>> opencode-sdd (config compartilhada) >>>"
BLOCK_END="# <<< opencode-sdd <<<"

# Remove bloco antigo (idempotente: rodar de novo atualiza o caminho)
if [ -f "$RC_FILE" ] && grep -qF "$BLOCK_START" "$RC_FILE"; then
  awk -v s="$BLOCK_START" -v e="$BLOCK_END" '
    $0==s {skip=1; next}
    $0==e {skip=0; next}
    !skip
  ' "$RC_FILE" > "$RC_FILE.tmp" && mv "$RC_FILE.tmp" "$RC_FILE"
fi

{
  echo "$BLOCK_START"
  echo "export OPENCODE_CONFIG_DIR=\"$SCRIPT_DIR\""
  echo "export OPENCODE_CONFIG=\"$SCRIPT_DIR/opencode.jsonc\""
  echo "$BLOCK_END"
} >> "$RC_FILE"

echo "✓ Config instalada."
echo "  OPENCODE_CONFIG_DIR=$SCRIPT_DIR"
echo "  OPENCODE_CONFIG=$SCRIPT_DIR/opencode.jsonc"
echo "  Gravado em: $RC_FILE"
echo
echo "  Agora rode:  source $RC_FILE   (ou abra um terminal novo)"
echo "  Depois valide:  opencode debug config"
