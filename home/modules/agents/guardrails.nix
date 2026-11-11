# One list of guardrails, rendered into each harness's own syntax: OpenCode's `permission`
# block (home/modules/opencode/) and Claude Code's settings.json (below), so the two
# cannot drift apart. These stop the agent's file tools, not a determined shell command
# (`cat .env` through bash); treat them as accident prevention.
{ config, lib, ... }:
let
  cfg = config.agents;
in
{
  options.agents.protect = {
    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "*.env"
        "*.env.*"
        "*.age"
        "*.key"
      ];
      description = "File name globs the agent may not read, at any depth.";
    };

    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "secrets" ];
      description = "Directory names whose contents the agent may not read, at any depth.";
    };

    confirm = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "darwin-rebuild switch"
        # An .envrc runs code on load; approving one is the user's decision.
        "direnv allow"
        "direnv reload"
        "git commit"
        "git push"
        "kubectl apply"
        "kubectl delete"
        "rm -rf"
        "sudo"
      ];
      description = "Command prefixes the agent must ask about before running.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Claude Code merges this with project settings; deny wins over allow. `*.env.*` also
    # blocks `.env.example` (OpenCode's rules can allow it; Claude's cannot override a deny).
    agents.claudeSettings.permissions = {
      deny = map (f: "Read(**/${f})") cfg.protect.files ++ map (d: "Read(**/${d}/**)") cfg.protect.dirs;
      ask = map (c: "Bash(${c}:*)") cfg.protect.confirm;
    };
  };
}
