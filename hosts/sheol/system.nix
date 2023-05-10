{ pkgs, config, ... }: {
  networking.hostName = "sheol";
  networking.hostId = "aeab81c5"; # head -c 8 /etc/machine-id

  environment.systemPackages = with pkgs; [
    zfs
    # cudaPackages.cudatoolkit # TODO: we might not need this
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.bluetooth.enable = false;
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
