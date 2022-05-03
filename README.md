## Setup boot drive

1. Partition drive

    <!-- ```sh
    sudo parted /dev/disk/by-id/YOURDISKHERE
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 85%
    mkpart primary 85% 98%
    mkpart primary linux-swap 98% 100%
    quit
    ```

    OR -->

    ```sh
    sudo parted /dev/disk/by-id/YOURDISKHERE
    mklabel gpt
    mkpart ESP fat32 1MiB 512MiB
    mkpart primary 512MiB 100%
    quit
    ```

1. Setup LUKS
    1. sudo cryptsetup luksFormat --type=luks1 /dev/disk/by-id/YOURDISKHERE-part2
    1. sudo cryptsetup luksOpen /dev/disk/by-id/YOURDISKHERE-part2 crypt-root
    1. TODO: backup LUKS header
1. Setup LVM
    1. sudo pvcreate /dev/mapper/crypt-root
    1. sudo vgcreate vg /dev/mapper/crypt-root
    1. sudo lvcreate --extents 85%VG --name root vg
    1. sudo lvcreate --extents 13%VG --name home vg
    1. sudo lvcreate --extents 2%VG --name swap vg
1. Create file systems
    1. sudo mkfs.fat -F 32 /dev/disk/by-id/YOURDISKHERE-part1
    1. sudo mkswap -L swap /dev/vg/swap
    1. sudo mkfs.ext4 -L root /dev/vg/root
    1. sudo mkfs.btrfs /dev/vg/home
1. Mount file systems
    1. sudo mount /dev/vg/root /mnt
    1. sudo mkdir -p /mnt/boot/efi
    1. sudo mount /dev/disk/by-id/YOURDISKHERE-part1 /mnt/boot/efi
    1. sudo mkdir /mnt/home
    1. sudo mount /dev/vg/home /mnt/home
    1. sudo swapon /dev/vg/swap
1. sudo nixos-generate-config --root /mnt
   This will probably fail due to the BTRFS home dir. You can unmount the dir and run this command again, but you'll have to add this
    ```nix
    fileSystems."/home" =
        {
        device = "/dev/disk/by-uuid/9cf80a5a-a5f3-49b4-9517-3388098b2fd7";
        fsType = "btrfs";
        };
    ```
