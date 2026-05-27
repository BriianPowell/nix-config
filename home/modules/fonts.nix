# Home Manager fonts (macOS: ~/Library/Fonts/HomeManager via rsync).
#
# NixOS hosts also use modules/fonts.nix (system-wide fonts.packages).
# On Darwin, HM copies fonts from home.packages paths that provide share/fonts.
#
{ config, lib, pkgs, ... }:
let
  cfg = config.fonts;
in
{
  options.fonts = {
    enable = lib.mkEnableOption "install Nerd Fonts via Home Manager";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      description = "Font packages (must include share/fonts; synced on macOS).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.packages;
  };
}
