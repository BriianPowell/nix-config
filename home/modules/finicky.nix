# Finicky browser picker (macOS). Deploys ~/.finicky.js
#
# Per user (darwin): finicky.enable = true;
#
{ config, lib, pkgs, ... }:
let
  cfg = config.finicky;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.finicky = {
    enable = lib.mkEnableOption "Finicky default browser rules (macOS)";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "JavaScript config linked to ~/.finicky.js.";
    };
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    home.file.".finicky.js".source =
      if cfg.configFile != null then
        cfg.configFile
      else
        ../config/.finicky.js;
  };
}
