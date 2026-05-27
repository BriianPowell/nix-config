# Home Manager module: declarative iTerm2 (macOS) preferences.
#
# Per user:
#   iterm2.plistFile = /path/to/com.googlecode.iterm2.plist;
#   iterm2.dynamicProfiles = [ ./profiles.json ];
#
# See home/iterm2/README.md
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.iterm2;

  dynamicProfilesDir = "Library/Application Support/iTerm2/DynamicProfiles";

  # iTerm expects { "Profiles": [ { ... } ] }. Exports from "Save Profile as JSON"
  # are often a single profile object; wrap automatically.
  # iTerm stores PostScript names. Nerd Fonts v3 registers NF/NFM, not "NerdFont" filenames.
  fixFontName =
    value:
    if builtins.isString value then
      lib.pipe value [
        (lib.replaceStrings [ "JetBrainsMonoNerdFontMono" ] [ "JetBrainsMonoNFM" ])
        (lib.replaceStrings [ "JetBrainsMonoNerdFont" ] [ "JetBrainsMonoNF" ])
      ]
    else
      value;

  normalizeProfile =
    p:
    lib.mapAttrs (k: v: if lib.hasSuffix " Font" k then fixFontName v else v) p;

  wrapDynamicProfile =
    path:
    let
      raw = builtins.fromJSON (builtins.readFile path);
      base = if raw ? Profiles then raw else { Profiles = [ raw ]; };
      profiles = map (p: normalizeProfile p // cfg.extraSettings) base.Profiles;
      wrapped = {
        Profiles = profiles;
      };
    in
    pkgs.writeText "iterm2-${builtins.baseNameOf path}" (builtins.toJSON wrapped);

  dynamicProfileFiles = lib.listToAttrs (
    map (path: {
      name = "${dynamicProfilesDir}/${builtins.baseNameOf path}";
      value = {
        source = wrapDynamicProfile path;
      };
    }) cfg.dynamicProfiles
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
        Imported with defaults(1) on each activation. Quit iTerm2 before rebuilding
        if settings do not appear.
      '';
    };

    dynamicProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        JSON profile files installed under
        ~/Library/Application Support/iTerm2/DynamicProfiles/.
        Single-profile exports are wrapped in a Profiles array automatically.
      '';
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Keys merged into each dynamic profile (e.g. Command, Custom Command).
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

    home.activation.iterm2ImportPrefs = lib.mkIf (cfg.plistFile != null) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
        if [ -e "$PLIST" ]; then
          $DRY_RUN_CMD /usr/bin/defaults import com.googlecode.iterm2 "$PLIST"
          $DRY_RUN_CMD killall cfprefsd 2>/dev/null || true
        else
          echo "iTerm2: skipping defaults import (plist missing)"
        fi
      ''
    );
  };
}
