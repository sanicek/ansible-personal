import type { Plugin } from "@opencode-ai/plugin"
import type { Session, SessionStatus } from "@opencode-ai/sdk"

const SOUND = "/usr/share/sounds/freedesktop/stereo/message.oga"
const SETTLE_MS = 2_000

// --- Runtime guard for question.asked (not in v1 Event union) ---
interface QuestionAskedEvent {
  type: "question.asked"
  properties: {
    id: string
    sessionID: string
    questions: unknown[]
    tool?: unknown
  }
}

function isQuestionAsked(e: { type: string }): e is QuestionAskedEvent {
  if (e.type !== "question.asked") return false
  const p = (e as QuestionAskedEvent).properties
  return typeof p?.id === "string"
    && typeof p?.sessionID === "string"
    && Array.isArray(p?.questions)
}

export const NotifyPlugin: Plugin = async ({ client, directory, $ }) => {
  // --- Notification helper (captures $ from closure) ---
  function notify(title: string, body: string) {
    $`notify-send ${title} ${body} --app-name=opencode --icon=dialog-information`
      .quiet()
      .catch(() => {})
    $`paplay ${SOUND}`.quiet().catch(() => {})
  }

  // --- State ---
  let disposed = false

  // Per-root timer ownership: unique symbol per schedule, never reused
  const rootTokens = new Map<string, symbol>()
  // Per-root timer handles
  const timers = new Map<string, ReturnType<typeof setTimeout>>()

  // Monotonic session epochs, bumped synchronously on every status event
  const sessionEpochs = new Map<string, number>()
  // Monotonic topology epoch, bumped synchronously on session create/delete
  let topologyEpoch = 0

  // Human-input dedup set + tracked expiry timers for dispose cleanup
  const recentInputs = new Set<string>()
  const inputExpiryTimers = new Set<ReturnType<typeof setTimeout>>()

  // --- Root timer lifecycle ---

  function clearRootTimer(rootID: string) {
    const existing = timers.get(rootID)
    if (existing) {
      clearTimeout(existing)
      timers.delete(rootID)
    }
    // Delete token to invalidate in-flight callbacks.
    // scheduleRootCheck installs a fresh token immediately after.
    if (existing || rootTokens.has(rootID)) {
      rootTokens.delete(rootID)
    }
  }

  function scheduleRootCheck(rootID: string) {
    clearRootTimer(rootID)
    const token = Symbol()
    rootTokens.set(rootID, token)
    const scheduleRootEpoch = sessionEpochs.get(rootID) ?? 0

    const timer = setTimeout(async () => {
      try {
        // Phase 0: dispose / token gate
        if (disposed) return
        if (rootTokens.get(rootID) !== token) return

        // Phase 1: capture topology epoch before list
        const topoSnapshot = topologyEpoch

        let sessions: Session[]
        try {
          const list = await client.session.list({ query: { directory }, throwOnError: true })
          sessions = list.data
          if (!sessions) return
        } catch {
          return // fail closed
        }

        // Phase 2: gate checks after list
        if (disposed) return
        if (rootTokens.get(rootID) !== token) return

        // Phase 3: build parent→children index from flat list
        const childrenMap = new Map<string, string[]>()
        for (const s of sessions) {
          if (s.parentID) {
            const arr = childrenMap.get(s.parentID)
            if (arr) arr.push(s.id)
            else childrenMap.set(s.parentID, [s.id])
          }
        }

        // Phase 4: iterative tree traversal with cycle guard
        const treeIds = new Set<string>()
        const queue = [rootID]
        const visited = new Set<string>()
        while (queue.length > 0) {
          const id = queue.shift()!
          if (visited.has(id)) return // cycle → fail closed
          visited.add(id)
          treeIds.add(id)
          for (const child of childrenMap.get(id) ?? []) {
            queue.push(child)
          }
        }

        // Phase 5: capture session epochs for entire tree
        const treeEpochs = new Map<string, number>()
        for (const id of treeIds) {
          treeEpochs.set(id, sessionEpochs.get(id) ?? 0)
        }

        // Phase 6: gate check after tree derivation
        if (disposed) return
        if (rootTokens.get(rootID) !== token) return

        // Phase 7: fetch statuses
        let statusMap: Record<string, SessionStatus>
        try {
          const statuses = await client.session.status({ query: { directory }, throwOnError: true })
          statusMap = statuses.data ?? {}
        } catch {
          return // fail closed
        }

        // Phase 8: dispose / token gate (precedes epoch checks)
        if (disposed) return
        if (rootTokens.get(rootID) !== token) return

        // Phase 9: topology mismatch → reschedule instead of permanent drop
        if (topologyEpoch !== topoSnapshot) {
          scheduleRootCheck(rootID)
          return
        }

        // Phase 10: session epoch mismatch → drop (status changed)
        for (const [id, ep] of treeEpochs) {
          if ((sessionEpochs.get(id) ?? 0) !== ep) return
        }

        // Phase 11: verify root still has no parent
        const rootSession = sessions.find(s => s.id === rootID)
        if (!rootSession || rootSession.parentID) return

        // Phase 12: verify no tree member is busy/retry
        for (const id of treeIds) {
          const s = statusMap[id]
          if (s && (s.type === "busy" || s.type === "retry")) return
        }

        // Phase 13: root epoch must match value captured at scheduling time —
        // a later root-idle transition would have bumped it and scheduled a fresh timer
        if ((sessionEpochs.get(rootID) ?? 0) !== scheduleRootEpoch) return

        // All checks passed — notify
        notify("OpenCode", `Response ready — ${rootSession.title || "Unnamed session"}`)
      } finally {
        // Clean up only if this callback's entries are still unchanged
        if (timers.get(rootID) === timer) {
          timers.delete(rootID)
        }
        if (rootTokens.get(rootID) === token) {
          rootTokens.delete(rootID)
        }
      }
    }, SETTLE_MS)

    timers.set(rootID, timer)
  }

  // --- Tree walker: find root by parent chain ---
  async function findRoot(sessionID: string): Promise<Session | null> {
    const MAX_DEPTH = 32
    let current = sessionID
    for (let depth = 0; depth < MAX_DEPTH; depth++) {
      try {
        const result = await client.session.get({
          path: { id: current },
          query: { directory },
          throwOnError: true,
        })
        const info = result.data
        if (!info) return null
        if (!info.parentID) return info
        current = info.parentID
      } catch {
        return null
      }
    }
    return null
  }

  // --- Human-input dedup ---
  function notifyInput(key: string, title: string, body: string) {
    if (disposed) return
    if (recentInputs.has(key)) return
    recentInputs.add(key)
    const timer = setTimeout(() => {
      recentInputs.delete(key)
      inputExpiryTimers.delete(timer)
    }, 30_000)
    inputExpiryTimers.add(timer)
    notify(title, body)
  }

  // --- Plugin hooks ---

  return {
    async event({ event }) {
      if (disposed) return

      // -- Human input: question.asked (narrow runtime guard) --
      if (isQuestionAsked(event)) {
        notifyInput(
          `q:${event.properties.sessionID}:${event.properties.id}`,
          "OpenCode",
          "Input required — Question asked",
        )
        return
      }

      // -- Session status changes (synchronous epoch bump before any await) --
      if (event.type === "session.status") {
        const { sessionID, status } = event.properties

        // Bump session epoch synchronously
        sessionEpochs.set(sessionID, (sessionEpochs.get(sessionID) ?? 0) + 1)
        const capturedEpoch = sessionEpochs.get(sessionID)!

        // Find root asynchronously
        const root = await findRoot(sessionID).catch(() => null)
        if (!root) return

        // Verify epoch unchanged during ancestry walk
        if (sessionEpochs.get(sessionID) !== capturedEpoch) return

        if (status.type === "idle") {
          scheduleRootCheck(root.id)
        } else {
          clearRootTimer(root.id)
        }
        return
      }

      // -- Session created (synchronous epoch bumps before any await) --
      if (event.type === "session.created") {
        topologyEpoch++
        const { info } = event.properties
        sessionEpochs.set(info.id, (sessionEpochs.get(info.id) ?? 0) + 1)
        if (info.parentID) {
          sessionEpochs.set(info.parentID, (sessionEpochs.get(info.parentID) ?? 0) + 1)
          const root = await findRoot(info.parentID).catch(() => null)
          if (root) clearRootTimer(root.id)
        }
        return
      }

      // -- Session deleted (synchronous invalidation then cleanup) --
      if (event.type === "session.deleted") {
        topologyEpoch++
        const { info } = event.properties
        // Remove deleted session's epoch after topology guard is established
        sessionEpochs.delete(info.id)
        if (info.parentID) {
          sessionEpochs.set(info.parentID, (sessionEpochs.get(info.parentID) ?? 0) + 1)
        }
        clearRootTimer(info.id)
        if (info.parentID) {
          const root = await findRoot(info.parentID).catch(() => null)
          if (root) scheduleRootCheck(root.id)
        }
        return
      }

      // Ignore deprecated session.idle
    },

    async "permission.ask"(input, _output) {
      if (disposed) return
      notifyInput(
        `perm:${input.id}`,
        "OpenCode",
        `Input required — ${input.title || "Permission request"}`,
      )
    },

    async dispose() {
      disposed = true
      for (const t of timers.values()) clearTimeout(t)
      timers.clear()
      rootTokens.clear()
      for (const t of inputExpiryTimers) clearTimeout(t)
      inputExpiryTimers.clear()
      recentInputs.clear()
    },
  }
}
