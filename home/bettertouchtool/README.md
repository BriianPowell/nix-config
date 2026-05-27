# BetterTouchTool configuration (per user)

Managed by `home/modules/bettertouchtool.nix`. Cask: `hosts/boog-MBP/brew.nix`.

## One-time BTT setup

1. **Advanced → Scripting** → enable **Command Line** (socket server)
2. Optionally allow automatic preset imports

## Per-user setup

```nix
# users/darwin/bettertouchtool.nix
{
  programs.bettertouchtool = {
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
