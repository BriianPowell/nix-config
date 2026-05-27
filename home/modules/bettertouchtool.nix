# Home Manager module: BetterTouchTool preset import (macOS).
#
# Per user:
#   bettertouchtool.presetFile = /path/to/preset.json;
#
# Requires BTT → Advanced → Scripting → Command Line (socket server) enabled.
# See home/bettertouchtool/README.md
#
{ config, lib, ... }:
let
  cfg = config.bettertouchtool;

  bttcli = "/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli";
in
{
  options.bettertouchtool = {
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
      lib.mkIf (cfg.presetFile != null && cfg.importOnActivation) (
        let
          presetHash = builtins.hashFile "sha256" cfg.presetFile;
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          BTTCLI=${lib.escapeShellArg bttcli}
          PRESET="$HOME/.config/bettertouchtool/preset.json"
          HASH_DIR="$HOME/.config/bettertouchtool"
          HASH_FILE="$HASH_DIR/.preset-hash"
          SOCKET_HINT="$HASH_DIR/.socket-server-hint-shown"

          if [ ! -x "$BTTCLI" ]; then
            echo "BetterTouchTool: skipping preset import (install bettertouchtool cask)"
            exit 0
          fi

          $DRY_RUN_CMD mkdir -p "$HASH_DIR"
          NEW_HASH='${presetHash}'
          OLD_HASH=$($DRY_RUN_CMD cat "$HASH_FILE" 2>/dev/null || true)

          if [ "$NEW_HASH" = "$OLD_HASH" ]; then
            exit 0
          fi

          # Socket server must be enabled or every bttcli call fails.
          if ! $DRY_RUN_CMD "$BTTCLI" get_string_variable variableName=BTTDisabled default=0 &>/dev/null; then
            if [ ! -f "$SOCKET_HINT" ]; then
              echo "BetterTouchTool: enable Advanced → Scripting → Command Line, restart BTT, then rebuild."
              $DRY_RUN_CMD touch "$SOCKET_HINT"
            fi
            exit 0
          fi
          $DRY_RUN_CMD rm -f "$SOCKET_HINT"

          echo "BetterTouchTool: importing preset (hash changed)..."
          if $DRY_RUN_CMD "$BTTCLI" import_preset \
            path="$PRESET" \
            replaceExisting=${lib.boolToString cfg.replaceExisting}; then
            $DRY_RUN_CMD sh -c "echo $NEW_HASH > '$HASH_FILE'"
          else
            echo "BetterTouchTool: import_preset failed (check BTT is running and allows imports)."
            exit 0
          fi
        ''
      );
  };
}
