{ config, pkgs, epkgs, ... }:
{
  networking.hostName = "sheol"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.eno2.useDHCP = true;
  networking.interfaces.idrac.useDHCP = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22 # ssh
      2022 # et
      80 # http
      443 # https
    ];
    # allowedUDPPorts = [ ... ];
  };
}
