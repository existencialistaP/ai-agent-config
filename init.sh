#!/usr/bin/env bash
# Verificação única do repo do harness: falha no primeiro erro.
set -euo pipefail

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
cd "$REPO_ROOT"

./doctor.sh
./install.sh --dry-run
bats tests/install.bats

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -x doctor.sh install.sh mapping.sh
else
    printf '[init] aviso: shellcheck ausente; lint dos scripts ignorado\n' >&2
fi

printf '[init] ok: doctor + install --dry-run + bats + shellcheck\n'
