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

  presetName =
    if cfg.presetFile != null then
      (builtins.fromJSON (builtins.readFile cfg.presetFile)).BTTPresetName or "exported preset"
    else
      "";
in
{
  options.bettertouchtool = {
    enable = lib.mkEnableOption "manage BetterTouchTool preset import";

    presetFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Exported BTT preset (.json or .bttpreset; both are JSON).
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

    forceImport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, run import_preset on every activation (ignores .preset-hash).
        Use once after fixing import issues, then set back to false.
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
          # Do not use exit here — HM runs activations in one script; exit skips linkGeneration.
          BTTCLI=${lib.escapeShellArg bttcli}
          PRESET="$HOME/.config/bettertouchtool/preset.json"
          HASH_DIR="$HOME/.config/bettertouchtool"
          HASH_FILE="$HASH_DIR/.preset-hash"
          SOCKET_HINT="$HASH_DIR/.socket-server-hint-shown"
          PRESET_NAME=${lib.escapeShellArg presetName}
          FORCE_IMPORT=${lib.boolToString cfg.forceImport}

          if [ -x "$BTTCLI" ]; then
            $DRY_RUN_CMD mkdir -p "$HASH_DIR"
            NEW_HASH='${presetHash}'
            OLD_HASH=$($DRY_RUN_CMD cat "$HASH_FILE" 2>/dev/null || true)

            if [ "$FORCE_IMPORT" = "true" ] || [ "$NEW_HASH" != "$OLD_HASH" ]; then
              if $DRY_RUN_CMD "$BTTCLI" get_string_variable variableName=BTTDisabled default=0 &>/dev/null; then
                $DRY_RUN_CMD rm -f "$SOCKET_HINT"
                echo "BetterTouchTool: importing preset ''$PRESET_NAME..."
                IMPORT_OUT=$($DRY_RUN_CMD "$BTTCLI" import_preset \
                  path="$PRESET" \
                  replaceExisting=${lib.boolToString cfg.replaceExisting} 2>&1) || IMPORT_RC=$?
                IMPORT_RC=''${IMPORT_RC:-0}
                if [ -n "$IMPORT_OUT" ]; then
                  echo "$IMPORT_OUT"
                fi
                if [ "$IMPORT_RC" -eq 0 ]; then
                  $DRY_RUN_CMD sh -c "echo $NEW_HASH > '$HASH_FILE'"
                  echo "BetterTouchTool: preset imported. In BTT → Presets, select ''$PRESET_NAME if triggers are missing."
                else
                  echo "BetterTouchTool: import_preset failed (is BTT running? allow imports in Advanced → Scripting)."
                fi
              else
                if [ ! -f "$SOCKET_HINT" ]; then
                  echo "BetterTouchTool: enable Advanced → Scripting → Command Line, restart BTT, then rebuild."
                  $DRY_RUN_CMD touch "$SOCKET_HINT"
                fi
                echo "BetterTouchTool: skipping preset import (socket server not running)."
              fi
            fi
          else
            echo "BetterTouchTool: skipping preset import (install bettertouchtool cask)"
          fi
        ''
      );
  };
}
