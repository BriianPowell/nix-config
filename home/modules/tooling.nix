# Editor/tooling dotfiles: editorconfig, prettier, tmux, finicky (macOS), 1Password SSH agent.
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
    enable = lib.mkEnableOption "shared editor and tooling configuration files";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".editorconfig".source = "${dir}/.editorconfig";
      ".gemrc".source = "${dir}/.gemrc";
      ".prettierrc.js".source = "${dir}/.prettierrc.js";
    }
    // lib.optionalAttrs isDarwin {
      ".finicky.js".source = "${dir}/.finicky.js";
    };

    xdg.configFile = {
      "tmux/tmux.conf".source = "${dir}/tmux/tmux.conf";
    }
    // lib.optionalAttrs isDarwin {
      "1Password/ssh/agent.toml".source = "${dir}/1Password/ssh/agent.toml";
    };
  };
}
