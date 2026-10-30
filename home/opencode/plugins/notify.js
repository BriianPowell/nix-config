// Desktop notification when an OpenCode session finishes; local models are slow,
// so you can look away while they work. macOS only (uses osascript).
//
// One file for both plugin APIs, as https://v2.opencode.ai/docs/build/plugins/server/
// ("Support V1") describes: V2 reads the default export's `id` and `setup`, V1 calls
// `server`. Without a default export with an id, OpenCode 2 refuses to load the file.
//
// In V2 a finished turn is a session message of type "idle" (see the session message
// schema in the server's /openapi.json). The names of the stream events that carry it
// are not documented, so this matches any event whose type or payload says idle. Set
// OPENCODE_NOTIFY_DEBUG=1 to append every event type to /tmp/opencode-notify.log and
// tighten `isIdle` once you have seen the real names.
import { execFile } from "node:child_process"
import { appendFileSync } from "node:fs"

const notify = () =>
  execFile("osascript", ["-e", 'display notification "Session completed" with title "opencode"'], () => {})

const debug = (line) => {
  if (process.env.OPENCODE_NOTIFY_DEBUG) appendFileSync("/tmp/opencode-notify.log", line + "\n")
}

const isIdle = (event) => {
  if (/idle/i.test(event.type ?? "")) return true
  const data = event.data ?? event.properties ?? event.message
  return data?.type === "idle" && data?.outcome !== undefined
}

export default {
  id: "local.notify",

  // OpenCode 2
  async setup(ctx) {
    const controller = new AbortController()
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        debug(event.type)
        if (isIdle(event)) notify()
      }
    })().catch(() => {})
    return () => controller.abort()
  },

  // OpenCode 1
  async server() {
    return {
      event: async ({ event }) => {
        if (event.type === "session.idle") notify()
      },
    }
  },
}
