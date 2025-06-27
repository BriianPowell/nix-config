{ pkgs, config, ... }: {
  networking.hostName = "abaddon";
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  networking.hosts = {
    "127.0.0.2" = [ "abaddon" ];
    "10.0.2.11" = [ "abaddon" ];
  };
}
