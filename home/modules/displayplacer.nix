# displayplacer monitor layouts (macOS). Brew: hosts/boog-MBP/brew.nix
#
# Per user (darwin):
#   displayplacer = {
#     enable = true;
#     layoutFile = ../../home/displayplacer/desk-layout.sh;
#   };
#
{ config, lib, pkgs, ... }:
let
  cfg = config.displayplacer;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.displayplacer = {
    enable = lib.mkEnableOption "displayplacer layout script and display-desk helper";

    layoutFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Executable script run by the display-desk command (typically a
        displayplacer "id:…" … one-liner). Regenerate with displayplacer list.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && isDarwin && cfg.layoutFile != null) {
    home.file = {
      ".config/displayplacer/layout.sh" = {
        source = cfg.layoutFile;
        executable = true;
      };

      ".local/bin/display-desk" = {
        text = ''
          #!${pkgs.bash}/bin/bash
          exec "$HOME/.config/displayplacer/layout.sh"
        '';
        executable = true;
      };
    };
  };
}
