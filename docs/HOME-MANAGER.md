# Home Manager layout

## How configuration flows

```text
home/modules/*.nix        defines options and behaviour, one namespace per app
users/common/home.nix     modules every account enables, plus shared values
users/<name>/home.nix     what differs for that account
users/<name>/*.nix        app settings and files only that account uses
```

`home/default.nix` imports every module in `home/modules/`. A module does
nothing until it is enabled (`<app>.enable = true`), so importing all of them is
safe. Each account imports `users/common/home.nix` (which pulls in `home/`) and
then its own files.

**Convention:** one top-level option namespace per app (`git`, `fish`, `rectangle`,
...). Accounts set `enable` and overrides there, not `programs.<app>`; Home
Manager's own `programs.*` stay internal to the modules.

Personal values (identity, hosts, vault names, sync servers) never live in a
module. A module exposes an option with an empty default and the account supplies
the value:

| Option | Set in |
| --- | --- |
| `git.userName`, `git.userEmail` | `users/common/git.nix` |
| `git.signing`, `git.ignores` | `users/darwin/git.nix` |
| `atuin.settings.sync_address` | `users/common/atuin.nix` |
| `ssh.configFile` | `users/<name>/home.nix` (file next to it) |
| `tooling.onePasswordAgentConfig` | `users/darwin/home.nix` |

## Modules

| Module | Options | Files | Enabled in |
| --- | --- | --- | --- |
| Git | `git.*` | (Nix only) | `users/common/home.nix` |
| Fish | `fish.*` | `home/fish/` | `users/common/home.nix` |
| SSH | `ssh.*` | `users/<name>/ssh.config` | `users/common/home.nix` |
| Tmux | `tmux.*` | `home/config/tmux/` | `users/common/home.nix` |
| Tooling | `tooling.*` | `home/config/` (editorconfig, prettier, gemrc) | `users/common/home.nix` |
| Vim | `vim.*` | `home/vim/` | `users/common/home.nix` |
| Atuin | `atuin.*` | Nix (`config.toml`) | `users/common/home.nix` |
| Fonts | `fonts.*` | Nix | `users/darwin/home.nix` |
| Finicky | `finicky.*` | `home/config/.finicky.js` | `users/darwin/home.nix` |
| displayplacer | `displayplacer.*` | `home/displayplacer/` | `users/darwin/home.nix` |
| Rectangle | `rectangle.*` | Nix + optional JSON | `users/darwin/rectangle.nix` |
| iTerm2 | `iterm2.*` | `home/iterm2/*.plist` | `users/darwin/iterm2.nix` |
| BetterTouchTool | `bettertouchtool.*` | `home/bettertouchtool/*.json` | `users/darwin/bettertouchtool.nix` |

## Adding an account

1. Create `users/<name>/default.nix`. The NixOS (or nix-darwin) user, its trusted-user
   entry and its home-manager hook-up live here:

   ```nix
   {
     home-manager.users.<name> = {
       imports = [
         ../common/home.nix
         ./home.nix
       ];
     };
     nix.settings.trusted-users = [ "<name>" ];
     users.users.<name> = { /* isNormalUser, shell, ... */ };
   }
   ```

2. Create `users/<name>/home.nix` with whatever differs from `users/common/home.nix`,
   for example `ssh.configFile = ./ssh.config;`.
3. List the account on a host: `users = [ "<name>" ]` in `flake.nix`.
4. If it has a password or login keys, declare the secrets in its module (see
   `docs/SECRETS.md`).

macOS-only apps (`rectangle`, `iterm2`, `bettertouchtool`, ...) go in extra files
imported from the account's `default.nix`, as `users/darwin` does.

## nix-darwin (machine) vs Home Manager (user)

| Layer | Path | Example |
| --- | --- | --- |
| Machine | `hosts/boog-MBP/` | Dock, Homebrew base lists, `system.primaryUser` |
| Machine overrides | `users/darwin/machine.nix` | `machine.username`, `machine.homebrew.omitCasks` |
| User dotfiles | `users/darwin/*.nix`, `home/modules/` | git, fish, iTerm, BTT |

`machine.username` has no default: it must match the macOS account (and
`users.users.<name>`, `home-manager.users.<name>` and `/Users/<name>`). A Mac host
that does not set it fails to build.

## Rebuild

```bash
darwin-rebuild switch --flake .#boog-MBP
sudo nixos-rebuild switch --flake .#sheol
```
