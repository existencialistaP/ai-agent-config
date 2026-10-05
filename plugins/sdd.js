/**
 * OpenCode SDD — plugin da config compartilhada.
 *
 * Registra a pasta `skills/` deste repositório no config do OpenCode para
 * que as skills próprias da equipe (ex.: `context`) sejam descobertas sem
 * precisar de symlink nem editar o opencode.json de cada membro.
 *
 * Mesmo mecanismo usado pelo Superpowers: o hook `config` injeta o caminho
 * na config viva (singleton), então a descoberta lazy de skills enxerga.
 */
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const SddPlugin = async () => {
  // plugin em <repo>/plugins/, skills em <repo>/skills/
  const skillsDir = path.resolve(__dirname, "../skills");

  return {
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },
  };
};
