# Home Manager layout

## How configuration flows

```text
home/modules/*.nix     →  defines options + defaults (the “module manager”)
users/<host>/home.nix  →  enables modules (git.enable, fish.enable, …)
users/<host>/git.nix   →  per-user values (git.userName, signing, …)
users/darwin/*.nix     →  macOS-only apps (rectangle, iterm2, …)
```

Each user’s Home Manager imports `../../home` (all modules), then sets options in their own files. Modules read `config.<name>` and implement `home.file`, `programs.*`, activations.

**Convention:** one top-level option namespace per app (`git`, `fish`, `rectangle`, …). User modules set `enable` and overrides there—not `programs.<app>` (Home Manager’s built-in `programs.git` etc. stay internal to our modules).

**Examples**

```nix
# users/boog/home.nix — turn modules on
{ git.enable = true; fish.enable = true; }

# users/boog/git.nix — identity and overrides
{ git.userName = "…"; git.userEmail = "…"; }

# users/darwin/rectangle.nix — app-specific options
{ rectangle.settings = { launchOnLogin = true; }; }
```

Shared behavior lives in the module; per-user differences live under `users/`.

## File layout

| Module | Options | Files | Per-user config |
|--------|---------|-------|-----------------|
| Git | `git.*` | (Nix only) | `users/*/git.nix` |
| Tooling | `tooling.*` | `home/config/` | `users/*/home.nix` |
| Fish | `fish.*` | `home/fish/` | `users/*/home.nix` |
| SSH | `ssh.*` | `home/ssh/` | `users/*/home.nix` |
| Vim | `vim.*` | `home/vim/` | `users/*/home.nix` |
| Atuin | `atuin.*` | Nix (`config.toml`) | `users/*/home.nix` |
| Rectangle | `rectangle.*` | Nix + optional JSON | `users/darwin/rectangle.nix` |
| iTerm2 | `iterm2.*` | `home/iterm2/*.plist` | `users/darwin/iterm2.nix` |
| BetterTouchTool | `bettertouchtool.*` | `home/bettertouchtool/*.json` | `users/darwin/bettertouchtool.nix` |

## Adding a Home Manager user

```nix
home-manager.users.newuser = {
  imports = [
    ../../home
    ./git.nix
    ./home.nix
  ];
};
```

macOS-only: also import `rectangle.nix`, `iterm2.nix`, `bettertouchtool.nix` as needed.

## Rebuild

```bash
darwin-rebuild switch --flake .#boog-MBP
sudo nixos-rebuild switch --flake .#sheol
```
