{ pkgs, config, ... }: {
  networking.hostName = "sheol";
  networking.hostId = "aeab81c5"; # head -c 8 /etc/machine-id

  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;

  environment.systemPackages = with pkgs; [
    zfs
    # cudaPackages.cudatoolkit # TODO: we might not need this
    # nodePackages.prettier
    # helix # https://helix-editor.com/
    # httpie # https://httpie.io/
  ];


  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.bluetooth.enable = false;
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
