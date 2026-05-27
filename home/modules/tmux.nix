# Tmux (wraps programs.tmux).
#
# Per user: tmux.enable = true;
# Overrides: tmux.extraConfig, tmux.plugins, …
#
{ config, lib, pkgs, ... }:
let
  cfg = config.tmux;
  tmuxConf = ../config/tmux/tmux.conf;
in
{
  options.tmux = {
    enable = lib.mkEnableOption "tmux configuration";

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = builtins.readFile tmuxConf;
      description = "Extra lines merged into ~/.config/tmux/tmux.conf.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Additional tmux plugins (sensible is always included last).";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      sensibleOnTop = false;
      terminal = "tmux-256color";
      mouse = true;
      baseIndex = 1;

      plugins = cfg.plugins ++ [
        pkgs.tmuxPlugins.sensible
      ];

      extraConfig =
        cfg.extraConfig
        + ''

          # Reload (HM installs config under ~/.config/tmux/)
          bind r source-file ~/.config/tmux/tmux.conf
        '';
    }
    // lib.optionalAttrs config.fish.enable {
      shell = "${pkgs.fish}/bin/fish";
    };
  };
}
