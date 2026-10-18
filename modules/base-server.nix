{ pkgs, lib, ... }:
{
  system = {
    stateVersion = "24.11";
  };

  time.timeZone = lib.mkDefault "America/Los_Angeles";

  networking = {
    defaultGateway = "10.0.2.1";
    nameservers = [
      "10.0.2.1"
    ];
    useDHCP = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        2022 # et
        80 # http
        443 # https
      ];
    };

    enableIPv6 = false;

    networkmanager = {
      enable = false;
      dns = "systemd-resolved";
      dhcp = "dhcpcd";
    };
  };

  # mDNS implementation for Home Assistant in K3S
  # https://nixos.org/manual/nixos/unstable/options.html#opt-services.avahi.enable
  services.resolved = {
    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.enable
    enable = false;

    # https://nixos.org/manual/nixos/unstable/options.html#opt-services.resolved.settings
    # 26.05 removed `extraConfig` and renamed the dnssec/llmnr/dnsovertls/fallbackDns
    # options into `settings.Resolve`. The old DNSOverTLS value was misspelled
    # ("oppurtunistic").
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      LLMNR = "false";
      DNSOverTLS = "opportunistic";
      MulticastDNS = "yes";
      FallbackDNS = [ "10.0.2.1" ];
    };
  };

  services = {
    avahi.enable = false; # USE SYSTEMD-RESOLVED
    vscode-server.enable = true;
    eternal-terminal.enable = true;
  };
}
