// Desktop notification when an OpenCode session finishes; local models are slow,
// so you can look away while they work. macOS only (uses osascript).
// https://opencode.ai/docs/plugins/
export const NotifyPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`osascript -e 'display notification "Session completed" with title "opencode"'`
      }
    },
  }
}
