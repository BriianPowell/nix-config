{ config, pkgs, epkgs, ... }:
{
  networking.hostName = "sheol"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.enableIPv6 = true;
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;


  # Open ports in the firewall.
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22 # ssh
      2022 # et
      80 # http
      443 # https
    ];
  };

  # mDNS needed for Home Assistant
  # https://nixos.org/manual/nixos/unstable/options.html#opt-services.avahi.enable
  services.avahi = {
    enable = true;
    # nssmdns = true;
    reflector = true;
    # interfaces = [
    #   "enp0s31f6"
    #   "enp6s0i"
    #   "cni0"
    #   "lo"
    # ];
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      # domain = true;
    };
  };
}
