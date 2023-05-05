{ config, pkgs, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];

  # Prompt to Import Encrypted Zpool at boot
  boot.zfs.extraPools = [ "moriyya" ];

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  services.sanoid = {
    enable = true;
    templates.production = {
      frequently = 0;
      hourly = 36;
      daily = 30;
      monthly = 3;
      yearly = 0;
      autoprune = true;
      autosnap = true;
    };

    datasets.moriyya = {
      useTemplate = [ "production" ];
      recursive = true;
      processChildrenOnly = true;
    };
  };
}
