# OpenCode's permission block, built from agents.protect (home/modules/agents/guardrails.nix)
# so it matches the rules Claude Code gets, plus tools to disable outright.
{ config, lib, ... }:
let
  cfg = config.opencode;
  cfg' = config.agents;

  disabledToolPermissions = lib.genAttrs cfg.disabledTools (_: "deny");
in
{
  options.opencode = {
    disabledTools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "question"
        "todowrite"
      ];
      description = "Built-in tools to deny; each removed tool shrinks the system prompt.";
    };

    permission = lib.mkOption {
      type = lib.types.attrs;
      # Attribute names are serialised in sorted order and OpenCode applies the
      # last matching rule, so every "*" catch-all must sort before the specific
      # patterns below it (it does: "*" is a prefix of all of them).
      # Built from agents.protect (home/modules/agents/guardrails.nix), shared with Claude Code.
      default = {
        read = {
          "*" = "allow";
          "*.env.example" = "allow";
        }
        // lib.genAttrs cfg'.protect.files (_: "deny")
        // lib.listToAttrs (
          lib.concatMap (d: [
            (lib.nameValuePair "${d}/*" "deny")
            (lib.nameValuePair "*/${d}/*" "deny")
          ]) cfg'.protect.dirs
        );
        bash = {
          "*" = "allow";
        }
        // lib.genAttrs (map (c: "${c}*") cfg'.protect.confirm) (_: "ask");
      };
      defaultText = lib.literalExpression "read/bash rules derived from config.agents.protect";
      description = "Merged into the top-level permission block of opencode.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    opencode.settings.permission = cfg.permission // disabledToolPermissions;
  };
}
