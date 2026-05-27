# Finicky

Managed by `home/modules/finicky.nix` → `~/.finicky.js`.

Requires the Finicky cask (`hosts/boog-MBP/brew.nix`) and Finicky running at login.

## Per-user

```nix
{ finicky.enable = true; }
```

Override config path:

```nix
{ finicky.configFile = ../../home/config/.finicky.js; }
```
