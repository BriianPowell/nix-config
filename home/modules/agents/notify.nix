# Desktop notifications when an agent finishes or needs input, through each harness's own
# hooks. Claude Code gets Stop and Notification (Cursor imports them from
# ~/.claude/settings.json); Copilot gets agentStop in its own hooks file. OpenCode has
# its own plugin (home/opencode/plugins/notify.js).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;

  # Desktop notification for the hook-based harnesses (macOS only: osascript).
  # usage: agents-notify <label> <finished|input>
  # Hooks pass an event as JSON on stdin; it must be read, and for `input` (Claude Code's
  # Notification event, a permission prompt or an idle wait) it carries the message text.
  # Strings go to osascript as arguments, never spliced into the script, so nothing in an
  # event can inject AppleScript.
  # A 2 s debounce per kind stops one event notifying twice when Cursor also runs the
  # Claude Code hooks it imports from ~/.claude/settings.json (per kind, so a quick
  # "finished" cannot swallow an "input" prompt).
  notifyScript = pkgs.writeShellScript "agents-notify" ''
    label="$1"
    kind="$2"
    payload=$(cat)
    case "$kind" in
      input)
        msg=$(printf '%s' "$payload" | ${pkgs.jq}/bin/jq -r '.message // empty' 2>/dev/null)
        [ -n "$msg" ] || msg="Waiting for your input"
        ;;
      *) msg="Finished" ;;
    esac
    stamp="''${TMPDIR:-/tmp}/agents-notify.stamp"
    now=$(date +%s)
    last=$(cat "$stamp" 2>/dev/null || echo 0)
    [ $((now - last)) -ge 2 ] || exit 0
    echo "$now" >"$stamp"
    /usr/bin/osascript \
      -e 'on run argv' \
      -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
      -e 'end run' -- "$msg" "$label"
    exit 0
  '';

  claudeHook = kind: [
    {
      hooks = [
        {
          type = "command";
          command = "${notifyScript} 'Claude Code' ${kind}";
        }
      ];
    }
  ];
in
{
  options.agents.notify.enable = lib.mkEnableOption ''
    desktop notifications (macOS) when an agent finishes or needs input, through each
    harness's own hooks: Claude Code (Stop, Notification; Cursor imports these) and
    VS Code Copilot (agentStop). OpenCode has its own plugin (home/opencode/plugins)
  '';

  config = lib.mkIf (cfg.enable && cfg.notify.enable) {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "agents.notify.enable needs macOS (the script calls osascript).";
      }
    ];

    # Merged into ~/.claude/settings.json (see default.nix).
    # Stop: the agent finished a turn. Notification: it is waiting on you (permission
    # prompt or idle). Cursor imports these when Settings > Agents > Third-Party
    # Imports is on (it is by default).
    agents.claudeSettings.hooks = {
      Stop = claudeHook "finished";
      Notification = claudeHook "input";
    };

    # VS Code Copilot (its own harness) reads user hook files from ~/.copilot/hooks/.
    # It has no permission-prompt event, only agentStop. A separate file, so hooks
    # created in the VS Code UI are not overwritten.
    home.file.".copilot/hooks/agents-notify.json".source =
      (pkgs.formats.json { }).generate "copilot-notify-hooks.json"
        {
          version = 1;
          hooks.agentStop = [
            {
              type = "command";
              command = "${notifyScript} Copilot finished";
              timeoutSec = 10;
            }
          ];
        };
  };
}
