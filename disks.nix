{ config, pkgs, ... }:

{
  boot.initrd.luks.devices."crypt-root".device = "/dev/disk/by-id/dm-name-crypt-root";

  fileSystems."/" = {
    # device = pkgs.lib.mkOverride 0 "/dev/disk/by-id/dm-name-vg-root";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-id/dm-name-vg-home";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "nodiratime" "discard=async" ];
  };

  fileSystems."/boot/efi" = {
    # device = pkgs.lib.mkOverride 0 "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part1";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  swapDevices = [{
    device = "/dev/disk/by-id/dm-name-vg-swap";
    options = [ "defaults" "discard" ];
    # randomEncryption.enable = true;
  }];
}
