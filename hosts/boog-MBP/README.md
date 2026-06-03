# boog-MBP (nix-darwin)

Declarative **system** config for this Mac. User dotfiles are Home Manager (`users/darwin/`).

## Layout

| File | Role |
|------|------|
| `options.nix` | `machine.*` option schema (username, Homebrew overrides) |
| `defaults.nix` | `system.defaults.*` synced from macOS (dock, finder, trackpad, …) |
| `system.nix` | Keyboard, `primaryUser`, power, packages, activation |
| `brew.nix` | Base Homebrew taps/brews/casks/mas + merges `machine.homebrew` |
| `security.nix` | Touch ID sudo, etc. |

## Sync defaults from the live Mac

nix-darwin only manages keys exposed as [`system.defaults`](https://nix-darwin.github.io/nix-darwin/manual/index.html#system.defaults) options. Export current values, then merge into `defaults.nix`:

```bash
chmod +x scripts/darwin-export-defaults
./scripts/darwin-export-defaults | less
darwin-rebuild switch --flake .#boog-MBP
```

**Not managed here (by design):** dock app tiles (`persistent-apps`), per-window positions, analytics timestamps, and most ByHost-only blobs. Use `system.defaults.CustomUserPreferences` for one-off plist domains if needed.

**Also declarative elsewhere:** Homebrew (`brew.nix`), Home Manager (`users/darwin/`), Rectangle/BTT/iTerm2 plists.

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
