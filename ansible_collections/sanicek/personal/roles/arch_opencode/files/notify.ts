import type { Plugin } from "@opencode-ai/plugin"

const SOUND = "/usr/share/sounds/freedesktop/stereo/message.oga"
const DEBOUNCE_MS = 15_000 // only notify if session stays idle this long

export const NotifyPlugin: Plugin = async ({ $ }) => {
  let debounceTimer: ReturnType<typeof setTimeout> | null = null

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Debounce: reset timer on each idle event. Only notify when
        // the session has been continuously idle for DEBOUNCE_MS,
        // filtering out brief pauses between subagent dispatches.
        if (debounceTimer) clearTimeout(debounceTimer)
        debounceTimer = setTimeout(() => {
          debounceTimer = null
          $`notify-send "OpenCode" "Response ready" --app-name=opencode --icon=dialog-information`.quiet().catch(() => {})
          $`paplay ${SOUND}`.quiet().catch(() => {})
        }, DEBOUNCE_MS)
      }
    },
  }
}
