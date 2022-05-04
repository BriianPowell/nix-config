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
    device = "/dev/disk/by-partuuid/cad7be81-9d07-4d20-aa14-8b41ea4357c0";
    options = [ "defaults" "discard" ];
    randomEncryption.enable = true;
  }];
}
