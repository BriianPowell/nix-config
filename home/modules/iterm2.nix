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
  wrapDynamicProfile =
    path:
    let
      raw = builtins.fromJSON (builtins.readFile path);
      base = if raw ? Profiles then raw else { Profiles = [ raw ]; };
      profiles = map (p: p // cfg.extraSettings) base.Profiles;
      wrapped = {
        Profiles = profiles;
      };
    in
    pkgs.writeText "iterm2-${builtins.baseNameOf path}" (builtins.toJSON wrapped);

  dynamicProfileStaged = lib.listToAttrs (
    map (path: {
      name = ".config/iterm2/dynamic-profiles/${builtins.baseNameOf path}";
      value = {
        source = wrapDynamicProfile path;
      };
    }) cfg.dynamicProfiles
  );

  dynamicProfileLinks = lib.concatMapStringsSep "\n" (
    path:
    let
      fileName = builtins.baseNameOf path;
    in
    ''
      $DRY_RUN_CMD ln -sfn "$HOME/.config/iterm2/dynamic-profiles/${fileName}" "$HOME/${dynamicProfilesDir}/${fileName}"
    ''
  ) cfg.dynamicProfiles;
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
        Does not use defaults(1); safe with the read-only HM-managed plist symlink.
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
      dynamicProfileStaged
    ];

    # Symlink into Application Support (avoids fragile home.file keys with spaces).
    home.activation.iterm2DynamicProfiles = lib.mkIf (cfg.dynamicProfiles != [ ]) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "$HOME/${dynamicProfilesDir}"
        ${dynamicProfileLinks}
      ''
    );
  };
}
