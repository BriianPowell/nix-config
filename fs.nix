{ config, pkgs, epkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
  ];

  networking.hostId = "aeab81c5"; # head -c 8 /etc/machine-id

  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];

  boot.zfs.extraPools = [ "moriyya" ];

  # TODO: services.zfs.trim.enable = true;
  # TODO: services.sanoid
}
