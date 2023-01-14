{ config, pkgs, epkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
  ];

  networking.hostId = "aeab81c5"; # head -c 8 /etc/machine-id

  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];


  # TODO: IMPORT ENCRYPTED ZFS POOL

  boot.zfs.requestEncryptionCredentials = [ "moriyya" ];
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  # TODO: services.sanoid
}
