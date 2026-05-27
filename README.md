# Nix Configurations

<details>

## Sheol Installation

- Encrypted root using LUKS
- Swap is turned off for this install as it will primarily be using K3S

### Setup Boot Drive

  1. Partition drive

    sudo parted /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 100%
    set 1 esp on
    quit

  2. Create a LUKS key

    1. dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4

  3. Setup LUKS

    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2
    2. sudo cryptsetup luksAddKey /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root-key.bin
    3. sudo cryptsetup luksOpen /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root -d crypt-root-key.bin
    4. sudo cryptsetup luksHeaderBackup /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 --header-backup-file sheolLuksHeaderBackup

  4. Setup LVM

    1. sudo pvcreate /dev/mapper/crypt-root
    2. sudo vgcreate vg /dev/mapper/crypt-root
    3. sudo lvcreate --extents 85%VG --name root vg
    4. sudo lvcreate --extents 15%VG --name home vg

  5. Create File Systems

    1. sudo mkfs.fat -F 32 -n boot /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part1
    2. sudo mkfs.ext4 -L root /dev/vg/root
    3. sudo mkfs.btrfs -L home /dev/vg/home

  6. Mount File Systems

    1. sudo mount /dev/vg/root /mnt
    2. sudo mkdir -p /mnt/boot/efi
    3. sudo mount /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part1 /mnt/boot/efi
    4. sudo mkdir /mnt/home
    5. sudo mount /dev/vg/home /mnt/home

  7. Copy / Create Keys

    1. sudo mkdir -p /mnt/etc/secrets/initrd/
    2. sudo cp crypt-root-key.bin /mnt/etc/secrets/initrd/
    3. sudo chmod 000 /mnt/etc/secrets/initrd/*.bin
    4. sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
    5. sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

  8. sudo nixos-generate-config --root /mnt

  9. sudo nixos-install

  10. reboot

## Abaddon Installation

- Encrypted root using LUKS
- Swap is turned off for this install as it will primarily be using K3S

### Setup Boot Drive

  1. Partition drive

    sudo parted /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 100%
    set 1 esp on
    quit

  2. Create a LUKS key

    1. dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4

  3. Setup LUKS

    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2
    2. sudo cryptsetup luksAddKey /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root-key.bin
    3. sudo cryptsetup luksOpen /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root -d crypt-root-key.bin
    4. sudo cryptsetup luksHeaderBackup /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 --header-backup-file abaddonLuksHeaderBackup

  4. Setup LVM

    1. sudo pvcreate /dev/mapper/crypt-root
    2. sudo vgcreate vg /dev/mapper/crypt-root
    3. sudo lvcreate --extents 85%VG --name root vg
    4. sudo lvcreate --extents 15%VG --name home vg

  5. Create File Systems

    1. sudo mkfs.fat -F 32 -n boot /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part1
    2. sudo mkfs.ext4 -L root /dev/vg/root
    3. sudo mkfs.btrfs -L home /dev/vg/home

  6. Mount File Systems

    1. sudo mount /dev/vg/root /mnt
    2. sudo mkdir -p /mnt/boot/efi
    3. sudo mount /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part1 /mnt/boot/efi
    4. sudo mkdir /mnt/home
    5. sudo mount /dev/vg/home /mnt/home

  7. Copy / Create Keys

    1. sudo mkdir -p /mnt/etc/secrets/initrd/
    2. sudo cp crypt-root-key.bin /mnt/etc/secrets/initrd/
    3. sudo chmod 000 /mnt/etc/secrets/initrd/*.bin
    4. sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
    5. sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

  8. sudo nixos-generate-config --root /mnt

  9. sudo nixos-install

  10. reboot

## Recovering from a bad time

  1. Boot into recovery environment.
  2. sudo cryptsetup luksOpen /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root
  3. sudo vgscan
  4. Continue from [Setup Boot Drive](#setup-boot-drive)'s "Mount file systems" step.

</details>

## Failed FDE Password

When grub enters the rescue shell, use the following commands

```sh
cryptomount hdX,gptY    # Device to mount: drive X, GPT partition Y, this forces the re-prompt.
insmod normal           # Load the normal mode boot module.
normal                  # Enter normal mode and display the GRUB menu.
```

## Nix Flake Packages

- [Home Manager](https://github.com/nix-community/home-manager)
- [VSCode Server](https://github.com/msteen/nixos-vscode-server)
- [Nix Darwin](https://github.com/LnL7/nix-darwin)

## Commands

### Sheol

- `nixos-rebuild switch --flake .#sheol`
- `nixos-rebuild dry-activate --flake .#sheol`

### Abaddon

- `nixos-rebuild switch --flake .#abaddon`
- `nixos-rebuild dry-activate --flake .#abaddon`

### Gehenna (WSL)

Built on top of [nix-community/NixOS-WSL](https://github.com/nix-community/NixOS-WSL).

**First-time install (from Windows PowerShell):**

1. Enable WSL if you haven't already (requires WSL ≥ 2.4.4):

    ```powershell
    wsl --install --no-distribution
    ```

2. Download the latest `nixos.wsl` from the [NixOS-WSL releases](https://github.com/nix-community/NixOS-WSL/releases) and import it as `gehenna`:

    ```powershell
    wsl --install --from-file .\nixos.wsl --name gehenna
    wsl -d gehenna
    ```

3. Inside the new distro, clone this repo and switch to the `gehenna` host:

    ```bash
    sudo nix --experimental-features 'nix-command flakes' run \
      nixpkgs#git -- clone https://github.com/briianpowell/nix-config /etc/nixos
    cd /etc/nixos
    sudo nixos-rebuild switch --flake .#gehenna
    ```

4. **agenix secrets**: this host overrides `hashedPasswordFile` to `null` so first-boot doesn't depend on decrypting secrets. To enable the rest of the agenix secrets on `gehenna`, copy its SSH host key into `secrets/secrets.nix` and re-encrypt:

    ```bash
    # On gehenna:
    cat /etc/ssh/ssh_host_ed25519_key.pub
    # On a machine with your agenix identity, add the key to `hosts` in
    # secrets/secrets.nix, then:
    cd secrets && agenix -r
    ```

**Day-to-day rebuilds (from inside the WSL distro):**

- `sudo nixos-rebuild switch --flake .#gehenna`
- `sudo nixos-rebuild dry-activate --flake .#gehenna`

### Darwin (boog-MBP)

Mac configuration via [nix-darwin](https://github.com/LnL7/nix-darwin). Home Manager user config lives under `users/darwin/`. Dotfiles are a flake input (`github:briianpowell/dotfiles`) used for fish, SSH, iTerm2 plist, and Rectangle.

**First-time installation:**

```bash
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

Then build and switch:

```bash
nix build .#darwinConfigurations.boog-MBP.system
./result/sw/bin/darwin-rebuild switch --flake .#boog-MBP
```

**Day-to-day rebuilds:**

```bash
darwin-rebuild switch --flake .#boog-MBP
darwin-rebuild check --flake .#boog-MBP
```

After changing [dotfiles](https://github.com/briianpowell/dotfiles):

```bash
nix flake update dotfiles
darwin-rebuild switch --flake .#boog-MBP
```

Use `--impure` if the flake eval fails on an uncommitted git tree.

**Display layout (`displayplacer`):**

Installed via Homebrew in `hosts/boog-MBP/brew.nix`. Persistent display IDs **change** when you unplug monitors, swap cables, or rearrange the desk. If a command fails with `Unable to find screen …`, the README/script is stale—regenerate it:

```bash
displayplacer list
# Copy the full `displayplacer "id:…" "id:…" …` line printed at the bottom.
```

Apply the current four-monitor layout (or run `scripts/display-desk.sh`):

```bash
./scripts/display-desk.sh
```

Equivalent one-liner:

```bash
displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2056x1329 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:EA121D52-37E7-494B-846B-E4883A08C049 res:2560x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(5496,0) degree:0" "id:22572CD6-50D0-4A20-947F-3DDEB101C6ED res:3440x1440 hz:100 color_depth:8 enabled:true scaling:off origin:(2056,0) degree:0" "id:BAF3A479-B2BD-4ECF-8359-F6673EC3BF89 res:2560x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(8056,0) degree:0"
```

| Display ID | Role (approx.) |
| --- | --- |
| `37D8832A-2D66-02CA-B9F7-8F30A301B230` | MacBook built-in (2056×1329, 120 Hz) |
| `22572CD6-50D0-4A20-947F-3DDEB101C6ED` | Ultrawide center (3440×1440, 100 Hz) |
| `EA121D52-37E7-494B-846B-E4883A08C049` | 27″ external right (2560×1440) |
| `BAF3A479-B2BD-4ECF-8359-F6673EC3BF89` | 27″ external far right (2560×1440) |

### Revert Generations

```bash
sudo nix-env --switch-generation 12345 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Attribution

Inspiration and adoption from [@DudeofAwesome](https://github.com/dudeofawesome/nix-server). The guy who usually sends me down these rabbit holes. Hoping to turn this repo into a central deployment configuration for my RPi's and other devices.
