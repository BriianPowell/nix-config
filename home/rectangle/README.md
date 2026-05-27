# Rectangle configuration (per user)

Managed by `home/modules/rectangle.nix`.

## Per-user setup

```nix
# users/darwin/rectangle.nix
{
  rectangle = {
    enable = true;
    settings = {
      reflowTodo = { keyCode = 45; modifierFlags = 786432; };
    };
  };
}
```

## Shared defaults (optional)

```nix
# home/default.nix
{ rectangle.settings.launchOnLogin = true; }
```

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
killall Rectangle; open -a Rectangle
```

## JSON export (full shortcuts)

1. `defaults write com.knollsoft.Rectangle showExportImport -bool true`
2. Quit Rectangle → Settings → Export → save as `home/rectangle/RectangleConfig.json`
3. `rectangle.jsonConfig = ../../home/rectangle/RectangleConfig.json; rectangle.bootstrapJson = true;`
4. Rebuild once, set `bootstrapJson = false`
