{ config, pkgs, ... }: {
  boot.supportedFilesystems = [ "zfs" ];
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
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

    # No snapshots of image layers: containerd's zfs snapshotter creates ~1500 datasets that
    # k3s can re-pull, and snapshotting them made each hourly run take ~40 minutes (110k+
    # snapshots) for no recovery value.
    templates.ignore = {
      autosnap = false;
      autoprune = false;
    };

    datasets.moriyya = {
      useTemplate = [ "production" ];
      recursive = true;
      processChildrenOnly = true;
    };

    # A more specific section overrides the recursive parent for this subtree.
    datasets."moriyya/containerd" = {
      useTemplate = [ "ignore" ];
      recursive = true;
    };
  };
}
