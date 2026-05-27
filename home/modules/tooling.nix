# Shared editor dotfiles: editorconfig, prettier, gemrc, 1Password SSH agent (macOS).
#
# Per user: tooling.enable = true;
#
{ config, lib, pkgs, ... }:
let
  cfg = config.tooling;
  dir = ../config;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.tooling = {
    enable = lib.mkEnableOption "shared editor configuration files";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".editorconfig".source = "${dir}/.editorconfig";
      ".gemrc".source = "${dir}/.gemrc";
      ".prettierrc.js".source = "${dir}/.prettierrc.js";
    };

    xdg.configFile = lib.optionalAttrs isDarwin {
      "1Password/ssh/agent.toml".source = "${dir}/1Password/ssh/agent.toml";
    };
  };
}
