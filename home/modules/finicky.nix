# Finicky browser picker (macOS). Deploys ~/.finicky.js
#
# Per user (darwin): finicky.enable = true;
#
{
  config,
  lib,
  pkgs,
  ...
}:
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
      description = "JavaScript config linked to ~/.finicky.js. Null writes a minimal one that opens everything in Safari.";
    };
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    home.file.".finicky.js" =
      if cfg.configFile != null then
        { source = cfg.configFile; }
      else
        {
          text = ''
            // ~/.finicky.js
            module.exports = {
              defaultBrowser: 'Safari',
              handlers: [],
            };
          '';
        };
  };
}
