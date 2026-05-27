# Home Manager module: declarative Rectangle (macOS) preferences.
#
# Per user:
#   rectangle.settings = { ... };
#
# See home/rectangle/README.md and users/darwin/rectangle.nix for examples.
#
{ config, lib, pkgs, ... }:
let
  cfg = config.rectangle;

  plistFile =
    pkgs.writeText "com.knollsoft.Rectangle.plist" (
      lib.generators.toPlist { escape = true; } cfg.settings
    );
in
{
  options.rectangle = {
    enable = lib.mkEnableOption "manage Rectangle preferences via defaults import";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Keys written to com.knollsoft.Rectangle.
        Merged from all Home Manager modules for this user.
      '';
    };

    bootstrapJson = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, copy jsonConfig into Application Support once (quit Rectangle first).
        Set back to false after one successful rebuild.
      '';
    };

    jsonConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "RectangleConfig.json path for one-time bootstrap.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.importRectanglePrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD /usr/bin/defaults import com.knollsoft.Rectangle ${lib.escapeShellArg plistFile}
    '';

    home.activation.bootstrapRectangleJson = lib.mkIf (cfg.bootstrapJson && cfg.jsonConfig != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        RECT_DIR="$HOME/Library/Application Support/Rectangle"
        $DRY_RUN_CMD mkdir -p "$RECT_DIR"
        $DRY_RUN_CMD cp -- ${lib.escapeShellArg cfg.jsonConfig} "$RECT_DIR/RectangleConfig.json"
      ''
    );
  };
}
