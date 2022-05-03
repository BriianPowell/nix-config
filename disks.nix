{ config, pkgs, ... }:

{
  fileSystems."/" = {
    # device = pkgs.lib.mkOverride 0 "/dev/disk/by-id/dm-name-vg-root";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/home" = {
    # device = "/dev/disk/by-id/dm-name-vg-home";
    options = [ "defaults" "noatime" "nodiratime" "discard=async" ];
  };

  fileSystems."/boot/efi" = {
    # device = pkgs.lib.mkOverride 0 "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANJ0NC40669A-part1";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/d3901638-60fd-45f1-9a8e-c88a71da0892";
    options = [ "defaults" "discard" ];
    randomEncryption.enable = true;
  }];
}
