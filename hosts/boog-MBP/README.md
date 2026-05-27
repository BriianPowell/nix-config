# boog-MBP (nix-darwin)

Declarative **system** config for this Mac. User dotfiles are Home Manager (`users/darwin/`).

## Layout

| File | Role |
|------|------|
| `options.nix` | `machine.*` option schema (username, Homebrew overrides) |
| `system.nix` | Dock, Finder, keyboard, `primaryUser`, system packages |
| `brew.nix` | Base Homebrew taps/brews/casks/mas + merges `machine.homebrew` |
| `security.nix` | Touch ID sudo, etc. |

## Per-user machine settings

Set values in `users/darwin/machine.nix`:

```nix
machine.homebrew.omitCasks = [ "signal" "steam" ];  # example: work laptop
machine.homebrew.extraCasks = [ "some-app" ];
```

`machine.username` must match `users.users.boog` and `home-manager.users.boog`.

## Rebuild

```bash
darwin-rebuild switch --flake .#boog-MBP
```
