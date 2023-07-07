{ pkgs, config, ... }: {
  networking.hostName = "abaddon";

  networking.interfaces.enp0s31f6.useDHCP = true;
}
