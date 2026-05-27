# Dotfiles → nix-config migration

Config formerly in the [dotfiles](https://github.com/briianpowell/dotfiles) repo now lives in this flake.

## Layout

| Module | Option | Files | Per-user enable |
|--------|--------|-------|-----------------|
| Git | `git.*` | (Nix only) | `users/{boog,darwin}/git.nix` |
| Tooling | `tooling.enable` | `home/config/` | `users/*/home.nix` |
| Fish | `fish.enable` | `home/fish/` | `users/*/home.nix` |
| SSH | `ssh.enable` | `home/ssh/` | `users/*/home.nix` |
| Vim | `vim.enable` | `home/vim/` | `users/*/home.nix` |
| Rectangle | `programs.rectangle` | Nix + optional JSON | `users/darwin/rectangle.nix` |
| iTerm2 | `programs.iterm2` | `home/iterm2/*.plist` | `users/darwin/iterm2.nix` |
| BetterTouchTool | `programs.bettertouchtool` | `home/bettertouchtool/*.json` | `users/darwin/bettertouchtool.nix` |

## Adding a Home Manager user

```nix
home-manager.users.newuser = {
  imports = [
    ../../home
    ../boog/git.nix      # or copy with new identity
    ../boog/home.nix     # enable fish, ssh, vim, tooling
  ];
};
```

macOS-only apps: import `users/darwin/rectangle.nix`, `iterm2.nix`, `bettertouchtool.nix` as needed.

## Rebuild

```bash
darwin-rebuild switch --flake .#boog-MBP
sudo nixos-rebuild switch --flake .#sheol
```
