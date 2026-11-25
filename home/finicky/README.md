# Finicky

Managed by `home/modules/finicky.nix` → `~/.finicky.js`.

Requires the Finicky cask (`hosts/<host>/brew.nix`) and Finicky running at login.

## Per-user

```nix
{ finicky.enable = true; }
```

Override config path:

```nix
{ finicky.configFile = ./finicky/finicky.js; }
```
