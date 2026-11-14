# shellcheck shell=bash
# shellcheck disable=SC2034  # os arrays sao consumidos por install.sh e doctor.sh
# Mapa unico de origem -> destino para o harness OMP.
# Quem der source precisa definir antes: OMP_DIR, HOME.
#
# Formato: "origem|destino". As origens sao relativas a raiz do repositorio.

# Links: um unico arquivo/diretorio fonte, sem copia.
link_sources=(
    "omp/AGENTS.md|$OMP_DIR/AGENTS.md"
    "omp/APPEND_SYSTEM.md|$OMP_DIR/APPEND_SYSTEM.md"
    "omp/config.yml|$OMP_DIR/config.yml"
    "omp/mcp.json|$OMP_DIR/mcp.json"
    "skills|$OMP_DIR/skills"
    "agents|$OMP_DIR/agents"
    "commands|$OMP_DIR/commands"
    "skills-janitor|$OMP_DIR/skills-janitor"
)

# Seeds mutaveis: copia somente se o destino ainda nao existir. OMP reescreve
# esses arquivos, entao uma versao live nunca e sobrescrita.
# O placeholder ${HOME} e resolvido na copia.
seed_sources=(
    "omp/plugins/omp-plugins.lock.json|$HOME/.omp/plugins/omp-plugins.lock.json"
    "omp/marketplaces.json|$HOME/.omp/marketplaces.json"
)

# Links criados por versoes anteriores deste repo (OpenCode/Codex). O install
# remove apenas os que resolvem para dentro deste checkout; arquivos reais e
# links de terceiros ficam intocados.
legacy_links=(
    "$HOME/.config/opencode/opencode.jsonc"
    "$HOME/.config/opencode/AGENTS.md"
    "$HOME/.config/opencode/commands"
    "$HOME/.config/opencode/skills"
    "$HOME/.config/opencode/agents"
    "$HOME/.config/opencode/skills-janitor"
    "$HOME/.config/opencode/plugins/adaptive-thinking.js"
    "$HOME/.codex/skills"
)
