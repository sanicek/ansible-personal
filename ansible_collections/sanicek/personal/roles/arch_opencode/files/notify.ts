import type { Plugin } from "@opencode-ai/plugin"

const SOUND = "/usr/share/sounds/freedesktop/stereo/message.oga"

export const NotifyPlugin: Plugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Fire and forget — don't block the event loop
        $`notify-send "OpenCode" "Response ready" --app-name=opencode --icon=dialog-information`.quiet().catch(() => {})
        $`paplay ${SOUND}`.quiet().catch(() => {})
      }
    },
  }
}
