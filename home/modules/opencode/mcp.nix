# MCP servers for OpenCode: presets (nixos, context7, github) and extra servers.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.opencode;

  # Servers are started from nix store paths, never `npx -y`, so nothing is
  # downloaded and run at launch. Each server adds its tool descriptions to every
  # request, which costs context on a local model, so presets stay few.
  githubMcp = pkgs.writeShellScript "github-mcp" ''
    ${
      if cfg.mcp.githubTokenRef != null then
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(op read ${lib.escapeShellArg cfg.mcp.githubTokenRef})"
      else
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(${pkgs.gh}/bin/gh auth token)"
    }
    export GITHUB_PERSONAL_ACCESS_TOKEN
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio \
      ${lib.optionalString cfg.mcp.githubReadOnly "--read-only"} \
      --toolsets repos,issues,pull_requests
  '';

  mcpPresets = {
    nixos = {
      type = "local";
      command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
    };
    context7 = {
      type = "local";
      command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
    };
    github = {
      type = "local";
      command = [ "${githubMcp}" ];
    };
  };
in
{
  options.opencode.mcp = {
    presets = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames mcpPresets));
      default = [ ];
      example = [
        "nixos"
        "context7"
      ];
      description = ''
        Ready-made MCP servers:
          nixos     NixOS, Home Manager and nix-darwin option and package lookup
          context7  current library documentation (queries leave the machine)
          github    repos, issues and pull requests (read-only by default)
      '';
    };

    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "Extra entries for the `mcp` block of opencode.json; same shape as OpenCode's mcp config.";
    };

    githubTokenRef = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "op://Private/GitHub MCP/token";
      description = ''
        1Password secret reference (not the secret) that the github preset reads
        with `op read` at launch. Null falls back to `gh auth token`, which carries
        whatever scopes `gh` was logged in with.
      '';
    };

    githubReadOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the github server with --read-only.";
    };
  };

  config = lib.mkIf (cfg.enable && (cfg.mcp.presets != [ ] || cfg.mcp.servers != { })) {
    opencode.settings.mcp = lib.genAttrs cfg.mcp.presets (name: mcpPresets.${name}) // cfg.mcp.servers;
  };
}
