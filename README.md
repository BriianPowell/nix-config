# Nix Server

<details>
  <summary>Installation</summary>

  - Encrypted root using LUKS
  - Swap is turned off for this install as it will primarily be using K3S

  ## Setup Boot Drive

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

  8. mkpasswd -m sha-512 | sudo tee /mnt/etc/passwd-boog

  9. sudo nixos-generate-config --root /mnt

  10. reboot

  ## Recovering from a bad time

  1. Boot into recovery environment.
  2. sudo cryptsetup luksOpen /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root
  3. sudo vgscan
  4. Continue from [Setup Boot Drive](#setup-boot-drive)'s "Mount file systems" step.

</details>

## Using Unstable Nix Channels

```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
sudo nix-channel --update nixpkgs
```

## Troubleshooting

### Random issues with Home Manager?

Try updating channels:

```sh
sudo nix-channel --update
```
