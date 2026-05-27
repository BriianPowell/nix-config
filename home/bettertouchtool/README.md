# BetterTouchTool configuration (per user)

Managed by `home/modules/bettertouchtool.nix`. Cask: `hosts/boog-MBP/brew.nix`.

## One-time BTT setup (required for automatic import)

1. Open **BetterTouchTool**
2. **Advanced → Scripting** → enable **Command Line** (socket server)
3. Quit and reopen BTT (or restart the app)
4. Optionally allow automatic preset imports (avoids a security prompt)

Test the socket:

```bash
/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli get_string_variable variableName=BTTDisabled default=0
```

If that prints a value (e.g. `0`) instead of an error, rebuild:

```bash
darwin-rebuild switch --flake .#boog-MBP
```

## Per-user setup

```nix
# users/darwin/bettertouchtool.nix
{
  bettertouchtool = {
    enable = true;
    presetFile = ../../home/bettertouchtool/BooG.bttpreset;
  };
}
```

## Export / update preset

BTT → **Presets** → **Export** → save as `home/bettertouchtool/BooG.bttpreset` (or `.json`), then rebuild.

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
```

Preset import runs when the file hash changes. See module for `importOnActivation`.

## Troubleshooting

**Import skipped:** activation only runs when `bttdata.json` changes. Force a re-import:

```bash
rm ~/.config/bettertouchtool/.preset-hash
darwin-rebuild switch --flake .#boog-MBP
```

Or temporarily set `bettertouchtool.forceImport = true` in `users/darwin/bettertouchtool.nix`.

**Triggers still missing:** `import_preset` loads the preset but does not always switch to it. In BTT → **Presets**, select the preset named in your JSON (`BTTPresetName`, e.g. `bttdata_DC065B49-…`).

**Socket / CLI errors:** enable **Advanced → Scripting → Command Line**, restart BTT, then rebuild.
