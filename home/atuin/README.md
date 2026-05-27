# Atuin configuration

Managed by `home/modules/atuin.nix` via `programs.atuin`.

## Defaults (in module)

- `sync_address = "https://atuin.powell.place"`
- `enter_accept = true`
- `sync.records = true` (sync v2)

## Per-user overrides

```nix
# users/boog/atuin.nix (optional)
{
  atuin.settings = {
    search_mode = "fuzzy";
  };
}
```

Or only enable in `users/*/home.nix`:

```nix
{ atuin.enable = true; }
```

Fish integration is on by default when `fish.enable` is true. Requires `atuin login` once for sync.

## Reference

Full option list: <https://docs.atuin.sh/configuration/config/>
