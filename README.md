# Nix Configurations

Declarative system and home configuration for NixOS, nix-darwin, and NixOS-WSL hosts.

**New machine or reinstall?** See [INSTALL.md](docs/INSTALL.md).

**Home Manager layout:** [home/MIGRATION.md](home/MIGRATION.md).

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

Use `--impure` if the flake eval fails on an uncommitted git tree. First-time Mac setup: [INSTALL.md#darwin-boog-mbp](INSTALL.md#darwin-boog-mbp).

First-time Darwin setup: [Install.md#darwin-boog-mbp](docs/INSTALL.md#darwin-boog-mbp)

### Revert generations

```bash
sudo nix-env --switch-generation 12345 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Attribution

Inspiration and adoption from [@DudeofAwesome](https://github.com/dudeofawesome/nix-server). The guy who usually sends me down these rabbit holes. Hoping to turn this repo into a central deployment configuration for my RPi's and other devices.
