{ lib, ... }: {
  system.stateVersion = "22.11";
  sound.enable = false;

  time.timeZone = lib.mkDefault "America/Los_Angeles";

  networking = {
    useDHCP = false;
    useNetworkd = true;

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

    # networkmanager = {
    #   enable = true;
    #   dns = "systemd-resolved";
    #   dhcp = "dhcpcd";
    # };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-enp6s0" = {
        matchConfig.Name = "enp6s0";
        networkConfig = {
          DHCP = "ipv4";
          LLMNR = "resolve";
          MulticastDNS = true;
          LinkLocalAddressing = "no";
          DNSOverTLS = "opportunistic";
          DNSSEC = "allow-downgrade";
        };
        linkConfig.RequiredForOnline = "no";
      };
      "10-enp0s3" = {
        matchConfig.Name = "enp0s31f6";
        networkConfig = {
          DHCP = "ipv4";
          LLMNR = "resolve";
          MulticastDNS = true;
          LinkLocalAddressing = "no";
          DNSOverTLS = "opportunistic";
          DNSSEC = "allow-downgrade";
        };
        linkConfig.RequiredForOnline = "no";
      };
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

  programs = {
    fish.enable = true;
  };
}
