# Shared editor dotfiles: editorconfig, prettier, gemrc, 1Password SSH agent (macOS).
#
# Per user: tooling.enable = true;
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tooling;
  dir = ../config;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.tooling = {
    enable = lib.mkEnableOption "shared editor configuration files";

    onePasswordAgentConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "1Password SSH agent config (agent.toml), macOS only. It lists vault and item names, so each user supplies their own.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".editorconfig".source = "${dir}/.editorconfig";
      ".gemrc".source = "${dir}/.gemrc";
      ".prettierrc.js".source = "${dir}/.prettierrc.js";
    };

    xdg.configFile = lib.optionalAttrs (isDarwin && cfg.onePasswordAgentConfig != null) {
      "1Password/ssh/agent.toml".source = cfg.onePasswordAgentConfig;
    };
  };
}
