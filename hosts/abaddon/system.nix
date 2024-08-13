{ pkgs, config, ... }: {
  networking.hostName = "abaddon";
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
}
