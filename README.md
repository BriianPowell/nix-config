## Setup boot drive

1. Partition drive

    <!-- ```sh
    sudo parted /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 85%
    mkpart primary 85% 98%
    mkpart primary linux-swap 98% 100%
    quit
    ```

    OR -->

    ```sh
    sudo parted /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 98%
    mkpart primary linux-swap 98% 100%
    quit
    ```

1. Create a LUKS key
   TODO: is this the best way to generate a key? I don't think so.
   dd if=/dev/random of=./crypt-root-key.bin bs=1024 count=4
1. Setup LUKS
    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2
    1. sudo cryptsetup luksAddKey /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root-key.bin
    1. sudo cryptsetup luksOpen /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root -d crypt-root-key.bin
    1. TODO: backup LUKS header
1. Setup LVM
    1. sudo pvcreate /dev/mapper/crypt-root
    1. sudo vgcreate vg /dev/mapper/crypt-root
    1. sudo lvcreate --extents 85%VG --name root vg
    1. sudo lvcreate --extents 15%VG --name home vg
1. Create file systems
    1. sudo mkfs.fat -F 32 /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part1
    1. sudo mkswap -L swap /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part3
    1. sudo mkfs.ext4 -L root /dev/vg/root
    1. sudo mkfs.btrfs -L home /dev/vg/home
1. Mount file systems
    1. sudo mount /dev/vg/root /mnt
    1. sudo mkdir -p /mnt/boot/efi
    1. sudo mount /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part1 /mnt/boot/efi
    1. sudo mkdir /mnt/home
    1. sudo mount /dev/vg/home /mnt/home
    1. sudo swapon /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part3
1. Copy / create the keys
    1. sudo mkdir -p /mnt/etc/secrets/initrd/
    1. sudo cp crypt-root-key.bin /mnt/etc/secrets/initrd/
    1. `sudo chmod 000 /mnt/etc/secrets/initrd/*.bin`
    1. sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
1. mkpasswd | sudo tee /mnt/etc/passwd-dudeofawesome
1. sudo nixos-generate-config --root /mnt
1. remove the `swapDevices` section from `hardware-configuration.nix`
   The file's header says not to modify it manually, so YMMV.
   https://github.com/NixOS/nixpkgs/issues/86353
1. `sudo mv ~/mynix/* /mnt/etc/nixos/; sudo nixos-install; sudo nixos-enter`
    1. nixos-install --root /; exit
       See [failed to create directory via template](https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f?permalink_comment_id=4011408#gistcomment-4011408)
1. reboot

## Recovering from a bad time

1. Boot into recovery environment.
1. sudo cryptsetup luksOpen /dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part2 crypt-root
1. sudo vgscan
1. Continue from [Setup Boot Drive](#setup-boot-drive)'s "Mount file systems" step.
