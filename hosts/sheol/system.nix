{ pkgs,  ... }: {
  networking.hostName = "sheol";
  networking.hostId = "aeab81c5"; # head -c 8 /etc/machine-id

  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.bluetooth.enable = false;
}
