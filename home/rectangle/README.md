# Rectangle configuration (per user)

Rectangle is managed by the Home Manager module `home/modules/rectangle.nix`.

## Per-user setup

Each macOS account with Home Manager gets its own `programs.rectangle` block.

**Example** — `users/darwin/rectangle.nix` (Brian_Powell):

```nix
programs.rectangle = {
  enable = true;
  settings = {
    reflowTodo = { keyCode = 45; modifierFlags = 786432; };
  };
};
```

**Another macOS user** — add e.g. `users/darwin/other-user.nix` and import it from `users/darwin/default.nix`:

```nix
home-manager.users.other-user = {
  imports = [ import ../../home ./other-user-rectangle.nix ];
};
```

Linux users (`boog` on NixOS) do not enable Rectangle; the module stays off unless you set `programs.rectangle.enable = true` on darwin only.

## Shared defaults (optional)

Put settings common to every Mac user in `home/default.nix`:

```nix
programs.rectangle.settings = {
  launchOnLogin = true;
};
```

User-specific modules override via Home Manager merge (later imports win for duplicate keys).

## Apply

```bash
darwin-rebuild switch --flake .#boog-MBP
killall Rectangle; open -a Rectangle
```

## JSON export (full shortcuts)

1. `defaults write com.knollsoft.Rectangle showExportImport -bool true`
2. Quit Rectangle → Settings → Export → save as `home/rectangle/RectangleConfig.json`
3. In your user's config: `jsonConfig = ../../home/rectangle/RectangleConfig.json; bootstrapJson = true;`
4. Rebuild once, set `bootstrapJson = false`

## Capture live settings

```bash
defaults export com.knollsoft.Rectangle - | plutil -convert json -o - -
```

`modifierFlags` reference: [Rectangle #185](https://github.com/rxhanson/Rectangle/issues/185#issuecomment-559198822)
