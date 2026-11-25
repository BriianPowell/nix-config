# Atuin configuration

Managed by `home/modules/atuin.nix` via `programs.atuin`.

## Defaults (in module)

- `enter_accept = true`
- `sync.records = true` (sync v2)

The sync server is not set here. Each fork sets `atuin.settings.sync_address` in its own
`users/<name>/atuin.nix` (or leaves it unset to use Atuin's default).

## Per-user overrides

```nix
# users/<name>/atuin.nix (optional)
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
