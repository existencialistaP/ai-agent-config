# shellcheck shell=bash
# shellcheck disable=SC2034  # os arrays sao consumidos por install.sh e doctor.sh
# Mapa unico de origem -> destino, compartilhado por install.sh e doctor.sh.
# Quem der source precisa definir antes: CONFIG_DIR, OMP_DIR, HOME.
#
# Formato: "origem|destino". As origens sao relativas a raiz do repositorio,
# exceto as de segunda ordem (OMP consome o que o OpenCode ja consome).

# Links: um unico arquivo/diretorio fonte, sem copia.
link_sources=(
    "opencode/opencode.jsonc|$CONFIG_DIR/opencode.jsonc"
    "opencode/AGENTS.md|$CONFIG_DIR/AGENTS.md"
    "opencode/agents|$CONFIG_DIR/agents"
    "opencode/commands|$CONFIG_DIR/commands"
    "opencode/skills|$CONFIG_DIR/skills"
    "opencode/plugins/adaptive-thinking.js|$CONFIG_DIR/plugins/adaptive-thinking.js"
    "opencode/skills-janitor|$CONFIG_DIR/skills-janitor"
    "omp/AGENTS.md|$OMP_DIR/AGENTS.md"
    "omp/APPEND_SYSTEM.md|$OMP_DIR/APPEND_SYSTEM.md"
    "omp/config.yml|$OMP_DIR/config.yml"
    "omp/mcp.json|$OMP_DIR/mcp.json"
    "omp/agents|$OMP_DIR/agents"
)

# Segunda ordem: o OMP aponta para o que ja esta publicado pelo OpenCode.
link_derived=(
    "$CONFIG_DIR/commands|$OMP_DIR/commands"
    "$CONFIG_DIR/skills|$OMP_DIR/skills"
)

# Seeds mutaveis: copia somente se o destino ainda nao existir. Orca/herdr/OMP
# reescrevem esses arquivos, entao uma versao live nunca e sobrescrita.
# O placeholder ${HOME} é resolvido na copia.
seed_sources=(
    "opencode/cli.json|$CONFIG_DIR/cli.json"
    "opencode/tui.jsonc|$CONFIG_DIR/tui.jsonc"
    "omp/plugins/omp-plugins.lock.json|$HOME/.omp/plugins/omp-plugins.lock.json"
    "omp/marketplaces.json|$HOME/.omp/marketplaces.json"
)
