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
    presetFile = ../../home/bettertouchtool/bttdata.json;
  };
}
```

## Export / update preset

BTT → **Presets** → **Export** → save as `home/bettertouchtool/bttdata.json`, then rebuild.

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
```

Preset import runs when the file hash changes. See module for `importOnActivation`.
