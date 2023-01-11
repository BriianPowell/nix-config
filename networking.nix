{ config, pkgs, epkgs, ... }:
{
  networking.hostName = "sheol"; # Define your hostname.
  networking.defaultGateway = "10.0.0.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.enableIPv6 = true;
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;

  # networking.useNetworkd = true;

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
  services.avahi.enable = false;

  services.resolved = {
    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.enable
    enable = true;

    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.dnssec
    dnssec = "allow-downgrade";

    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.llmnr
    llmnr = "resolve";

    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.extraConfig
    extraConfig = ''
      DNSOverTLS=opportunistic
      MulticastDNS=yes
    '';

    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.fallbackDns
    fallbackDns = [ "1.0.0.1" "2606:4700:4700::1001" ];
  };
}
