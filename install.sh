#!/usr/bin/env bash
set -euo pipefail

# Instala a config compartilhada da equipe fazendo symlinks dos diretórios do
# repo (agents, commands, skills) para ~/.config/opencode/. Assim o `git pull`
# atualiza tudo automaticamente, sem copiar arquivos.
#
# Rode a partir de qualquer lugar:  bash ~/.config/opencode-sdd/install.sh
# (ou clone o repo direto em ~/.config/opencode-sdd e rode de lá).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

# Guarda: nunca apontar para o próprio repositório (evita auto-symlink destrutivo).
if [ "$(cd "$CONFIG_DIR" 2>/dev/null && pwd -P)" = "$(cd "$REPO_DIR" && pwd -P)" ]; then
  echo "ERRO: CONFIG_DIR resolve para o próprio repositório." >&2
  echo "Rode: unset OPENCODE_CONFIG_DIR OPENCODE_CONFIG  e tente de novo." >&2
  exit 1
fi

echo "Repositório : $REPO_DIR"
echo "Config dir  : $CONFIG_DIR"
echo

mkdir -p "$CONFIG_DIR"

# 1) Agents, commands e skills — symlink do diretório inteiro.
for d in agents commands skills; do
  src="$REPO_DIR/$d"
  dst="$CONFIG_DIR/$d"
  if [ -L "$dst" ]; then
    echo "✓ $d já é symlink -> $(readlink "$dst")"
  elif [ -e "$dst" ]; then
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "! $d já existia como pasta real; movido para $backup"
    ln -sfn "$src" "$dst"
    echo "✓ $dst -> $src"
  else
    ln -sfn "$src" "$dst"
    echo "✓ $dst -> $src"
  fi
done

# 2) Config (opencode.json / opencode.jsonc)
echo
if [ -f "$CONFIG_DIR/opencode.json" ] || [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
  echo "Você já tem um opencode.json/opencode.jsonc pessoal. Adicione manualmente"
  echo "estas chaves (não sobrescrevi nada):"
  echo
  echo '  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]'
  echo '  "model": "opencode-go/deepseek-v4-pro"'
  echo '  "small_model": "opencode-go/deepseek-v4.1-flash"'
  echo
  echo "As permissões do /context (se quiser) estão em $REPO_DIR/opencode.jsonc."
else
  cp "$REPO_DIR/opencode.jsonc" "$CONFIG_DIR/opencode.jsonc"
  echo "✓ $CONFIG_DIR/opencode.jsonc criado a partir do da equipe"
fi

echo
echo "Concluído. Reinicie o OpenCode e valide com:  opencode debug agents"
