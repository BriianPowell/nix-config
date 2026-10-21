# Nix Configurations

Declarative system and home configuration for NixOS, nix-darwin, and NixOS-WSL hosts.

**New machine or reinstall?** See [INSTALL.md](docs/INSTALL.md).

## Docs

| Doc | What it covers |
| --- | --- |
| [docs/INSTALL.md](docs/INSTALL.md) | New machine or reinstall: Sheol, Abaddon, Gehenna (WSL), Darwin |
| [docs/HOME-MANAGER.md](docs/HOME-MANAGER.md) | How user config is layered; adding an account |
| [docs/SECRETS.md](docs/SECRETS.md) | Where each secret is declared; users, hosts and re-keying |
| [secrets/ssh/README.md](secrets/ssh/README.md) | SSH secret runbook: login keys, deploy keys, host key check |
| [hosts/boog-MBP/README.md](hosts/boog-MBP/README.md) | The Mac host layout and syncing macOS defaults |
| [docs/MULTI-USER-PLAN.md](docs/MULTI-USER-PLAN.md) | Why the repo is laid out this way for forks, and what is left |


## Using this repo

The repo is built so a fork can run its own machines by replacing a few files, not
by editing shared modules. Nothing under `modules/` or `home/` holds a personal
value.

| To add... | Do this |
| --- | --- |
| a **site** (a network and who administers it) | Copy `sites/home.nix` to `sites/<name>.nix` and fill in `site.servers.{gateway,dns}`, `site.hosts.<hostname>.ip` and `site.initrdAuthorizedKeys`. There are no defaults, so a missing value fails the build and names the option. |
| a **user** | Create `users/<name>/` (see [docs/HOME-MANAGER.md](docs/HOME-MANAGER.md#adding-an-account)): the NixOS account, `nix.settings.trusted-users`, and its secrets. |
| a **server host** | Create `hosts/<hostname>/` with the values only that machine has: disk UUIDs (`server.disks`), LUKS UUID and NIC drivers (`server.luksUuid`, `server.nicDrivers`), and its `networking.interfaces`. Import your site file from `hosts/<hostname>/default.nix`, then add it in `flake.nix` with `role = ./modules/server;` and `users = [ "<name>" ]`. |
| a **WSL host** | Same, with `role = ./modules/wsl;` plus `extraModules = [ nixos-wsl.nixosModules.default ];`. The host only sets `networking.hostName` and `wsl.defaultUser`. |
| **secrets** | Add the host key to `secrets/keys.nix` and to `hosts` in `secrets/secrets.nix`, then `agenix -r`. A fork replaces both files' keys with its own. See [docs/SECRETS.md](docs/SECRETS.md). |
| the **initrd unlock host keys** | Generate them on the server at install time (`/etc/secrets/initrd/`); see [docs/INSTALL.md](docs/INSTALL.md). |

Every Linux host also gets the `root` account, which declares its password secret
from `secrets/passwords/users/root.age`. A fork must re-key that file (or replace
`users/root`) before it can activate.

`nix flake check` also builds a made-up server from only a site and a user
(`tests/fork-example`, `checks.<system>.fork-example`) and fails if any of this
repo's own values show up in it, so a change that hard-codes something personal is
caught before it reaches a fork.

## Nix flake packages

- [Home Manager](https://github.com/nix-community/home-manager)
- [VSCode Server](https://github.com/msteen/nixos-vscode-server)
- [Nix Darwin](https://github.com/LnL7/nix-darwin)

## Commands

### Sheol

```bash
nixos-rebuild switch --flake .#sheol
nixos-rebuild dry-activate --flake .#sheol
```

### Abaddon

```bash
nixos-rebuild switch --flake .#abaddon
nixos-rebuild dry-activate --flake .#abaddon
```

### Gehenna (WSL)

```bash
sudo nixos-rebuild dry-activate --flake .#gehenna
sudo nixos-rebuild switch --flake .#gehenna
```

First-time WSL setup: [INSTALL.md#gehenna-wsl](docs/INSTALL.md#gehenna-wsl).

### Darwin (boog-MBP)

```bash
sudo darwin-rebuild check --flake .#boog-MBP
sudo darwin-rebuild switch --flake .#boog-MBP
```

Use `--impure` if the flake eval fails on an uncommitted git tree. First-time Mac setup: [INSTALL.md#darwin-boog-mbp](docs/INSTALL.md#darwin-boog-mbp).

### Revert generations

```bash
sudo nix-env --switch-generation 12345 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Attribution

Inspiration and adoption from [@DudeofAwesome](https://github.com/dudeofawesome/nix-server). The guy who usually sends me down these rabbit holes. Hoping to turn this repo into a central deployment configuration for my RPi's and other devices.
