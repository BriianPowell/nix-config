# Home Manager module: BetterTouchTool preset import (macOS).
#
# Per user:
#   programs.bettertouchtool.presetFile = /path/to/preset.json;
#
# Requires BTT → Advanced → Scripting → Command Line (socket server) enabled.
# See home/bettertouchtool/README.md
#
{ config, lib, ... }:
let
  cfg = config.programs.bettertouchtool;

  bttcli = "/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli";
in
{
  options.programs.bettertouchtool = {
    enable = lib.mkEnableOption "manage BetterTouchTool preset import";

    presetFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Exported BTT preset JSON (Presets → Export).
        Imported via bttcli when the file hash changes.
      '';
    };

    replaceExisting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Passed to bttcli import_preset replaceExisting.";
    };

    importOnActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        When true, run import_preset after deploy if presetFile changed
        (tracked via ~/.config/bettertouchtool/.preset-hash).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkIf (cfg.presetFile != null) {
      ".config/bettertouchtool/preset.json".source = cfg.presetFile;
    };

    home.activation.bettertouchtoolImportPreset =
      lib.mkIf (cfg.presetFile != null && cfg.importOnActivation)
        (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            BTTCLI=${lib.escapeShellArg bttcli}
            PRESET=${lib.escapeShellArg cfg.presetFile}
            HASH_DIR="$HOME/.config/bettertouchtool"
            HASH_FILE="$HASH_DIR/.preset-hash"

            if [ ! -x "$BTTCLI" ]; then
              echo "BetterTouchTool: skipping preset import (install bettertouchtool cask)"
              exit 0
            fi

            $DRY_RUN_CMD mkdir -p "$HASH_DIR"
            NEW_HASH=$($DRY_RUN_CMD shasum -a 256 "$PRESET" | awk '{print $1}')
            OLD_HASH=$($DRY_RUN_CMD cat "$HASH_FILE" 2>/dev/null || true)

            if [ "$NEW_HASH" = "$OLD_HASH" ]; then
              exit 0
            fi

            echo "BetterTouchTool: importing preset (hash changed)..."
            if $DRY_RUN_CMD "$BTTCLI" import_preset \
              path="$PRESET" \
              replaceExisting=${lib.boolToString cfg.replaceExisting}; then
              $DRY_RUN_CMD sh -c "echo '$NEW_HASH' > '$HASH_FILE'"
            else
              echo "BetterTouchTool: import failed — enable Command Line / Socket Server in BTT → Scripting, restart BTT, rebuild."
              exit 0
            fi
          ''
        );
  };
}
