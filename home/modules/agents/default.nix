# Shared agent setup for Claude Code, OpenCode, Cursor and VS Code Copilot.
#
#   context.nix     generated machine context (CLAUDE.md, OpenCode AGENTS.md, machine.md)
#   guardrails.nix  agents.protect: files the agent may not read, commands it must ask about
#   notify.nix      desktop notifications through each harness's hooks
#   (this file)     the options everything shares, ~/.claude/settings.json, and linking the
#                   shared /bootstrap command and skills (home/opencode/) into each harness
#
# Per user: agents.enable = true;
# Overrides: agents.extraInstructions, agents.nixConfigPath, agents.protect.*, agents.notify.enable
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agents;
in
{
  imports = [
    ./context.nix
    ./guardrails.nix
    ./notify.nix
  ];

  options.agents = {
    enable = lib.mkEnableOption "generated machine context for AI agents";

    nixConfigPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Code/Self/nix-config";
      description = "Where the nix-config checkout lives on this machine.";
    };

    # Fragments from guardrails.nix and notify.nix; merged into one settings.json here.
    claudeSettings = lib.mkOption {
      inherit (pkgs.formats.json { }) type;
      default = { };
      internal = true;
      description = "Claude Code settings.json content, merged from the agents modules.";
    };
  };

  config = lib.mkIf cfg.enable {
    # A read-only store symlink: Claude's own "always allow" choices go to the project's
    # .claude/settings.local.json, not here.
    home.file.".claude/settings.json".source = (pkgs.formats.json { }).generate "claude-settings.json" (
      {
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      }
      // cfg.claudeSettings
    );

    # The commands and skills are written once (home/opencode/) and linked into every
    # harness. Per-file links keep these directories real: other tools install into
    # ~/.claude/skills and ~/.cursor/skills too. Frontmatter keys a harness does not
    # know (OpenCode's `agent:`) are ignored by the others.
    home.file = {
      ".claude/commands" = {
        source = ../../opencode/commands;
        recursive = true;
      };
      ".claude/skills" = {
        source = ../../opencode/skills;
        recursive = true;
      };
      ".cursor/commands" = {
        source = ../../opencode/commands;
        recursive = true;
      };
      ".cursor/skills" = {
        source = ../../opencode/skills;
        recursive = true;
      };
    };
  };
}
