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
    # device = pkgs.lib.mkOverride 0 "/dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0-part1";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };
}
