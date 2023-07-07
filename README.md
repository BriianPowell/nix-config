# Nix Configuration for Sheol

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

    TODO: is this the best way to generate a key? I don't think so.
    1. dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4

  3. Setup LUKS

    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2
    2. sudo cryptsetup luksAddKey /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root-key.bin
    3. sudo cryptsetup luksOpen /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root -d crypt-root-key.bin
    4. TODO: backup LUKS header

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
    4. sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

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

    TODO: is this the best way to generate a key? I don't think so.
    1. dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4

  3. Setup LUKS

    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2
    2. sudo cryptsetup luksAddKey /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root-key.bin
    3. sudo cryptsetup luksOpen /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root -d crypt-root-key.bin
    4. TODO: backup LUKS header

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
    4. sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

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
- [Flake Utils Plus](https://github.com/gytis-ivaskevicius/flake-utils-plus/tree/master)
- [VSCode Server](https://github.com/msteen/nixos-vscode-server)
- [Nix Darwin](https://github.com/LnL7/nix-darwin)

## Commands

- `nixos-rebuild switch` update nix environment with latest configuration
- `nixos-rebuild switch --flake .#sheol`
- `nixos-rebuild dry-activate --flake .#sheol`

### Darwin

**First Time Installation:**

```bash
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

- `nix build .#darwinConfigurations.boog-MBP.system` use nix build to create the initial installion
- `./result/sw/bin/darwin-rebuild switch --flake .#boog-MBP` use nix-darwin to use the configuration

**then:**

- `darwin-rebuild switch --flake .#boog-MBP`
- `darwin-rebuild check --flake .#boog-MBP`

### Revert Generations

```bash
sudo nix-env --switch-generation 12345 -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Attribution

Inspiration and adoptation from [@DudeofAwesome](https://github.com/dudeofawesome/nix-server). The guy who usually sends me down these rabbit holes. Hoping to turn this repo into a central deployment configuration for my RPi's and other devices.
