{ lib, ... }: {
  system.stateVersion = "23.05";
  sound.enable = false;

  time.timeZone = lib.mkDefault "America/Los_Angeles";

  networking = {
    defaultGateway = "10.0.2.1";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    useDHCP = false;

    firewall = {
      enable = false;
      allowedTCPPorts = [
        22 # ssh
        2022 # et
        80 # http
        443 # https
      ];
    };

    enableIPv6 = false;

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      dhcp = "dhcpcd";
    };
  };

  # mDNS implementation for Home Assistant in K3S
  # https://nixos.org/manual/nixos/unstable/options.html#opt-services.avahi.enable
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
    fallbackDns = [ "1.0.0.1" ];
  };

  services = {
    avahi.enable = false; # USE SYSTEMD-RESOLVED
    vscode-server.enable = true;
    eternal-terminal.enable = true;
  };
}
