import { Plugin } from "@opencode/plugin"

/**
 * Adaptive Thinking — V2 port of `opencode-adaptive-thinking` (V1 only).
 *
 * Original: https://github.com/ian-pascoe/opencode-adaptive-thinking
 * This reimplements its behavior on the OpenCode V2 plugin API:
 *  - injects reasoning-effort guidance into the session context
 *  - exposes a `set_reasoning_effort` tool that changes the model variant
 *  - a non-persisted level resets when the session goes idle
 *
 * V2 API note: in `@opencode/plugin` 2.x the catalog accessors (`get`, `list`)
 * live on the editor handed to `ctx.model.transform`, not on `ctx.model`
 * itself (`ctx.model.get(...)` throws "is not a function"). We capture that
 * editor once at setup and read variants from it at tool time.
 */

const DEFAULTS = {
  enabled: true,
  toolName: "set_reasoning_effort",
  toolDescription: "Set your reasoning effort",
  systemPrompt:
    "Ajuste o esforço de raciocínio só quando a dificuldade da tarefa mudar claramente " +
    "(ex.: de leitura simples para depuração difícil). Não reavalie a cada turno.",
}

/** sessionID -> { level, persist, providerID, modelID, variants } */
const state = new Map()

function variantNames(model) {
  const v = model?.variants
  if (!v) return []
  if (Array.isArray(v)) {
    return v.map((x) => (typeof x === "string" ? x : (x?.id ?? x?.name))).filter(Boolean)
  }
  if (typeof v === "object") return Object.keys(v)
  return []
}

export default Plugin.define({
  id: "adaptive-thinking",
  async setup(ctx) {
    const opts = ctx.options && typeof ctx.options === "object" ? ctx.options : {}
    const cfg = { ...DEFAULTS, ...opts }
    if (!cfg.enabled) return

    // 0) Keep a handle on the live model catalog. The editor is the only place
    //    that exposes `get`/`list` in the V2 plugin API.
    let catalog
    await ctx.model.transform((editor) => {
      catalog = editor
    })

    function modelEntry(providerID, modelID) {
      if (!providerID || !modelID || typeof catalog?.get !== "function") return undefined
      try {
        return catalog.get(providerID, modelID)
      } catch {
        return undefined
      }
    }

    // 1) Guidance + apply the chosen level to each outgoing request.
    // Discard the level when the new model does not support it.
    await ctx.session.hook("context", (event) => {
      const s = state.get(event.sessionID) ?? {}
      const entry = event.model ? modelEntry(event.model.providerID, event.model.id) : undefined
      const variants = event.model ? variantNames(entry) : (s.variants ?? [])
      const level = variants.includes(s.level) ? s.level : undefined
      if (level && event.model) event.model.variant = level
      state.set(event.sessionID, {
        ...s, level, variants,
        providerID: event.model?.providerID ?? s.providerID,
        modelID: event.model?.id ?? s.modelID,
      })
      event.system.push({ type: "text", text: cfg.systemPrompt })
    })

    // 2) Reset a non-persisted level once the session goes idle.
    const controller = new AbortController()
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        if (event.type === "session.idle") {
          const id = event.properties?.sessionID
          const s = id ? state.get(id) : undefined
          if (s && !s.persist) state.set(id, { ...s, level: undefined })
        } else if (event.type === "session.deleted") {
          const id = event.properties?.info?.id ?? event.properties?.sessionID
          if (id) state.delete(id)
        }
      }
    })().catch(() => {})

    // 3) The tool.
    await ctx.tool.transform((editor) => {
      editor.add({
        name: cfg.toolName,
        description: cfg.toolDescription,
        input: {
          type: "object",
          properties: {
            level: {
              type: "string",
              description:
                "The level of reasoning effort to apply. Higher levels may be more accurate but slower.",
            },
            persist: {
              type: "boolean",
              description:
                "Persist for the whole session; otherwise it applies only until the session goes idle.",
            },
          },
          required: ["level"],
          additionalProperties: false,
        },
        options: { codemode: true },
        execute: async (input, context) => {
          const level = String(input?.level ?? "")
          const persist = input?.persist === true
          const sid = context.sessionID
          const s = state.get(sid) ?? {}

          if (!level) return { content: "Failed to set reasoning effort: missing level." }

          // Prefer the variants captured for the current model; fall back to a
          // fresh catalog read in case the context hook has not run yet.
          const entry = modelEntry(s.providerID, s.modelID)
          const valid = Array.isArray(s.variants) && s.variants.length > 0
            ? s.variants
            : variantNames(entry)

          if (!entry && valid.length === 0) {
            return {
              content: `Cannot set reasoning effort: no model catalog entry for ${
                s.providerID && s.modelID ? `${s.providerID}/${s.modelID}` : "the current model"
              }.`,
            }
          }
          if (valid.length === 0) {
            return {
              content: `The current model (${s.providerID}/${s.modelID}) exposes no reasoning-effort variants.`,
            }
          }
          if (!valid.includes(level)) {
            return { content: `Invalid reasoning effort level: ${level}. Valid levels: ${valid.join(", ")}.` }
          }

          state.set(sid, { ...s, level, persist })
          return { content: `Reasoning effort set to ${level}${persist ? " (persisted)" : ""}.` }
        },
      })
    })

    return () => controller.abort()
  },
})
