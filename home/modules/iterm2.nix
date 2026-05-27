# Home Manager module: declarative iTerm2 (macOS) preferences.
#
# Per user:
#   iterm2.plistFile = /path/to/com.googlecode.iterm2.plist;
#   iterm2.dynamicProfiles = [ ./profiles.json ];
#
# See home/iterm2/README.md
#
{ config, lib, pkgs, ... }:
let
  cfg = config.iterm2;

  dynamicProfileFiles = lib.listToAttrs (
    map (path: {
      name = "Library/Application Support/iTerm2/DynamicProfiles/${builtins.baseNameOf path}";
      value = {
        source = path;
      };
    }) cfg.dynamicProfiles
  );

  extraSettingsPlist =
    lib.optional (cfg.extraSettings != { }) (
      pkgs.writeText "com.googlecode.iterm2-extra.plist" (
        lib.generators.toPlist { escape = true; } cfg.extraSettings
      )
    );
in
{
  options.iterm2 = {
    enable = lib.mkEnableOption "manage iTerm2 preferences";

    plistFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "${config.home.homeDirectory}/.config/iterm2.plist";
      description = ''
        Full preferences plist (com.googlecode.iterm2).
        Linked into ~/Library/Preferences/. Restart iTerm2 after changes.
      '';
    };

    dynamicProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        JSON files installed under
        ~/Library/Application Support/iTerm2/DynamicProfiles/.
      '';
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Top-level plist keys merged via defaults import after the main plist.
        Use for small per-user overrides; nested keys need a full plistFile.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge [
      (lib.mkIf (cfg.plistFile != null) {
        "Library/Preferences/com.googlecode.iterm2.plist" = {
          source = cfg.plistFile;
          force = true;
        };
      })
      dynamicProfileFiles
    ];

    home.activation.iterm2ExtraSettings = lib.mkIf (cfg.extraSettings != { }) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD /usr/bin/defaults import com.googlecode.iterm2 ${lib.escapeShellArg (builtins.head extraSettingsPlist)}
      ''
    );
  };
}
