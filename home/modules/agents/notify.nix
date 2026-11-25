# Desktop notifications when an agent finishes or needs input, through each harness's own
# hooks. Claude Code gets Stop and Notification; Cursor gets its own native `stop` hook
# (and ignores the Claude Code ones it would otherwise import); Codex gets Stop and
# PermissionRequest in ~/.codex/hooks.json; Copilot gets agentStop in its own hooks file.
# OpenCode has its own plugin (home/opencode/plugins/notify.js).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;

  # Desktop notification for the hook-based harnesses (macOS only: osascript).
  # usage: agents-notify <label> <finished|input|cursor-stop|codex-stop|codex-permission>
  # Hooks pass an event as JSON on stdin; it must be read. `input` (Claude Code's
  # Notification event, a permission prompt or an idle wait) carries the message text;
  # `cursor-stop` carries Cursor's status (completed, aborted, error); `codex-permission`
  # carries the tool name and, when Codex has one, its reason. Only those two fields are
  # shown, never the command itself, which can hold secrets.
  # Strings go to osascript as arguments, never spliced into the script, so nothing in an
  # event can inject AppleScript.
  # Cursor also runs the Claude Code hooks it imports from ~/.claude/settings.json, and sets
  # CURSOR_VERSION for every hook it runs. With the native hook installed those imported
  # runs stay silent (the native one reports); without it they notify as "Cursor", not
  # "Claude Code". A 2 s debounce per kind stops any remaining double notification, and a
  # quick "finished" cannot swallow an "input" prompt.
  notifyScript = pkgs.writeShellScript "agents-notify" ''
    label="$1"
    kind="$2"
    payload=$(cat)
    if [ -n "''${CURSOR_VERSION:-}" ] && [ "$label" = "Claude Code" ]; then
      ${if cfg.notify.cursor.native then "exit 0" else "label=Cursor"}
    fi
    case "$kind" in
      input)
        msg=$(printf '%s' "$payload" | ${pkgs.jq}/bin/jq -r '.message // empty' 2>/dev/null)
        [ -n "$msg" ] || msg="Waiting for your input"
        ;;
      cursor-stop)
        case $(printf '%s' "$payload" | ${pkgs.jq}/bin/jq -r '.status // empty' 2>/dev/null) in
          aborted) msg="Stopped" ;;
          error) msg="Stopped with an error" ;;
          *) msg="Finished" ;;
        esac
        ;;
      codex-permission)
        tool=$(printf '%s' "$payload" | ${pkgs.jq}/bin/jq -r '.tool_name // empty' 2>/dev/null)
        why=$(printf '%s' "$payload" | ${pkgs.jq}/bin/jq -r '.tool_input.description? // empty' 2>/dev/null)
        msg="Approval needed''${tool:+: $tool}"
        [ -z "$why" ] || msg="$msg ($why)"
        ;;
      *) msg="Finished" ;;
    esac
    stamp="''${TMPDIR:-/tmp}/agents-notify-$kind.stamp"
    now=$(date +%s)
    last=$(cat "$stamp" 2>/dev/null || echo 0)
    [ $((now - last)) -ge 2 ] || exit 0
    echo "$now" >"$stamp"
    /usr/bin/osascript \
      -e 'on run argv' \
      -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
      -e 'end run' -- "$msg" "$label"
    # Cursor and Codex read a JSON reply from a stop hook; an empty object means no
    # follow-up. Codex treats plain text from Stop as invalid. Its permission hook gets
    # no reply, so the normal approval prompt goes ahead.
    case "$kind" in cursor-stop | codex-stop) echo '{}' ;; esac
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
  options.agents.notify = {
    enable = lib.mkEnableOption ''
      desktop notifications (macOS) when an agent finishes or needs input, through each
      harness's own hooks: Claude Code (Stop, Notification), Cursor (stop), Codex (Stop,
      PermissionRequest) and VS Code Copilot (agentStop). OpenCode has its own plugin (home/opencode/plugins)
    '';

    cursor.native = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Add a native `stop` hook to ~/.cursor/hooks.json (merged in, other hooks kept) and
        silence the Claude Code hooks Cursor imports. Off: Cursor notifies through the
        imported hooks, titled "Cursor".
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.notify.enable) {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "agents.notify.enable needs macOS (the script calls osascript).";
      }
    ];

    # Merged into ~/.claude/settings.json (see default.nix).
    # Stop: the agent finished a turn. Notification: it is waiting on you (permission
    # prompt or idle).
    agents.claudeSettings.hooks = {
      Stop = claudeHook "finished";
      Notification = claudeHook "input";
    };

    # Cursor reads one user-level ~/.cursor/hooks.json, which also holds hooks written by
    # hand (beforeShellExecution), so this edits the file instead of owning it: it drops
    # any earlier agents-notify `stop` entry and adds the current one, leaving the rest.
    home.activation.agentsCursorStopHook = lib.mkIf cfg.notify.cursor.native (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        f="$HOME/.cursor/hooks.json"
        mkdir -p "$HOME/.cursor"
        [ -s "$f" ] || echo '{"version":1,"hooks":{}}' >"$f"
        tmp=$(mktemp)
        if ${pkgs.jq}/bin/jq --arg cmd "${notifyScript} Cursor cursor-stop" '
            .version //= 1
            | .hooks.stop = ((.hooks.stop // []) | map(select((.command // "") | contains("agents-notify") | not)) + [{command: $cmd}])
          ' "$f" >"$tmp"; then
          mv "$tmp" "$f"
        else
          rm -f "$tmp"
          echo "agents.notify: could not update $f (is it valid JSON?)" >&2
        fi
      ''
    );

    # Codex reads ~/.codex/hooks.json alongside config.toml (which the Codex app edits, so
    # it is left alone; hooks need `features.hooks = true` there, which the app sets). Codex
    # asks you to trust each hook once, by hash, with /hooks in the CLI; a rebuild that
    # changes the script changes the hash, so it asks again.
    home.file.".codex/hooks.json".source = (pkgs.formats.json { }).generate "codex-hooks.json" {
      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${notifyScript} Codex codex-stop";
                timeout = 10;
              }
            ];
          }
        ];
        PermissionRequest = [
          {
            hooks = [
              {
                type = "command";
                command = "${notifyScript} Codex codex-permission";
                timeout = 10;
              }
            ];
          }
        ];
      };
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
