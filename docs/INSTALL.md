# Installation

Host-specific install and recovery notes for this flake. Day-to-day rebuild commands stay in [README.md](README.md).

## Table of contents

- [Sheol (NixOS)](#sheol-nixos)
- [Abaddon (NixOS)](#abaddon-nixos)
- [Recovering from a bad time](#recovering-from-a-bad-time)
- [Failed FDE password (GRUB rescue)](#failed-fde-password-grub-rescue)
- [Gehenna (WSL)](#gehenna-wsl)
- [Darwin (boog-MBP)](#darwin-boog-mbp)

## Sheol (NixOS)

- Encrypted root using LUKS
- Swap is turned off for this install as it will primarily be using K3S

### Setup boot drive

1. Partition drive

   ```sh
   sudo parted /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0
   mklabel gpt
   mkpart ESP fat32 1MiB 512MiB
   mkpart primary 512MiB 100%
   set 1 esp on
   quit
   ```

2. Create a LUKS key

   ```sh
   dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4
   ```

3. Setup LUKS

   ```sh
   sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2
   sudo cryptsetup luksAddKey /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root-key.bin
   sudo cryptsetup luksOpen /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 crypt-root -d crypt-root-key.bin
   sudo cryptsetup luksHeaderBackup /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part2 --header-backup-file sheolLuksHeaderBackup
   ```

4. Setup LVM

   ```sh
   sudo pvcreate /dev/mapper/crypt-root
   sudo vgcreate vg /dev/mapper/crypt-root
   sudo lvcreate --extents 85%VG --name root vg
   sudo lvcreate --extents 15%VG --name home vg
   ```

5. Create file systems

   ```sh
   sudo mkfs.fat -F 32 -n boot /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part1
   sudo mkfs.ext4 -L root /dev/vg/root
   sudo mkfs.btrfs -L home /dev/vg/home
   ```

6. Mount file systems

   ```sh
   sudo mount /dev/vg/root /mnt
   sudo mkdir -p /mnt/boot/efi
   sudo mount /dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part1 /mnt/boot/efi
   sudo mkdir /mnt/home
   sudo mount /dev/vg/home /mnt/home
   ```

7. Copy / create keys

   ```sh
   sudo mkdir -p /mnt/etc/secrets/initrd/
   sudo cp crypt-root-key.bin /mnt/etc/secrets/initrd/
   sudo chmod 000 /mnt/etc/secrets/initrd/*.bin
   sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
   sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
   ```

8. Generate config and install

   ```sh
   sudo nixos-generate-config --root /mnt
   sudo nixos-install
   reboot
   ```

## Abaddon (NixOS)

- Encrypted root using LUKS
- Swap is turned off for this install as it will primarily be using K3S

### Setup boot drive

1. Partition drive

   ```sh
   sudo parted /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U
   mklabel gpt
   mkpart ESP fat32 1MiB 512MiB
   mkpart primary 512MiB 100%
   set 1 esp on
   quit
   ```

2. Create a LUKS key

   ```sh
   dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4
   ```

3. Setup LUKS

   ```sh
   sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2
   sudo cryptsetup luksAddKey /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root-key.bin
   sudo cryptsetup luksOpen /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 crypt-root -d crypt-root-key.bin
   sudo cryptsetup luksHeaderBackup /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part2 --header-backup-file abaddonLuksHeaderBackup
   ```

4. Setup LVM

   ```sh
   sudo pvcreate /dev/mapper/crypt-root
   sudo vgcreate vg /dev/mapper/crypt-root
   sudo lvcreate --extents 85%VG --name root vg
   sudo lvcreate --extents 15%VG --name home vg
   ```

5. Create file systems

   ```sh
   sudo mkfs.fat -F 32 -n boot /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part1
   sudo mkfs.ext4 -L root /dev/vg/root
   sudo mkfs.btrfs -L home /dev/vg/home
   ```

6. Mount file systems

   ```sh
   sudo mount /dev/vg/root /mnt
   sudo mkdir -p /mnt/boot/efi
   sudo mount /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U-part1 /mnt/boot/efi
   sudo mkdir /mnt/home
   sudo mount /dev/vg/home /mnt/home
   ```

7. Copy / create keys

   ```sh
   sudo mkdir -p /mnt/etc/secrets/initrd/
   sudo cp crypt-root-key.bin /mnt/etc/secrets/initrd/
   sudo chmod 000 /mnt/etc/secrets/initrd/*.bin
   sudo ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
   sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
   ```

8. Generate config and install

   ```sh
   sudo nixos-generate-config --root /mnt
   sudo nixos-install
   reboot
   ```

## Recovering from a bad time

1. Boot into recovery environment.
2. `sudo cryptsetup luksOpen /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root`
3. `sudo vgscan`
4. Continue from [Setup boot drive](#setup-boot-drive) step 6 (mount file systems) for the host you are recovering.

## Failed FDE password (GRUB rescue)

When GRUB enters the rescue shell:

```sh
cryptomount hdX,gptY    # Device to mount: drive X, GPT partition Y; forces re-prompt
insmod normal           # Load the normal mode boot module
normal                  # Enter normal mode and display the GRUB menu
```

## Gehenna (WSL)

Built on top of [nix-community/NixOS-WSL](https://github.com/nix-community/NixOS-WSL).

### First-time install (from Windows PowerShell)

1. Enable WSL if you have not already (requires WSL ≥ 2.4.4):

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

4. **agenix secrets**: this host overrides `hashedPasswordFile` to `null` so first boot does not depend on decrypting secrets. To enable the rest of the agenix secrets on `gehenna`, copy its SSH host key into `secrets/secrets.nix` and re-encrypt:

   ```bash
   # On gehenna:
   cat /etc/ssh/ssh_host_ed25519_key.pub
   # On a machine with your agenix identity, add the key to `hosts` in
   # secrets/secrets.nix, then:
   cd secrets && agenix -r
   ```

## Darwin (boog-MBP)

Mac configuration via [nix-darwin](https://github.com/LnL7/nix-darwin). Home Manager user config lives under `users/darwin/`. Dotfiles are a flake input (`github:briianpowell/dotfiles`) used for fish, SSH, iTerm2 plist, and Rectangle.

See also [hosts/boog-MBP/README.md](hosts/boog-MBP/README.md) for host layout.

### First-time install

Follow [nix-darwin step 1 (creating a flake)](https://github.com/nix-darwin/nix-darwin#step-1-creating-flakenix), then:

```bash
# Nixpkgs unstable:
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#boog-MBP

# Nixpkgs 25.11:
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch --flake .#boog-MBP
```

Then build and switch:

```bash
sudo darwin-rebuild check --flake .#boog-MBP
sudo darwin-rebuild switch --flake .#boog-MBP
```

Use `--impure` if the flake eval fails on an uncommitted git tree.
