{ config, ... }:
{
  networking = {
    defaultGateway = config.site.gateway;
    nameservers = config.site.dns;
    useDHCP = false;
    enableIPv6 = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        2022 # et
        80 # http
        443 # https
      ];
    };
  };

  # resolved itself is off (the default), but the systemd initrd builds its own
  # resolved.conf from these settings, so removing them changes the initrd.
  services.resolved.settings.Resolve = {
    DNSSEC = "allow-downgrade";
    LLMNR = "false";
    DNSOverTLS = "opportunistic";
    MulticastDNS = "yes";
    FallbackDNS = config.site.dns;
  };

  services.eternal-terminal.enable = true;

  # A switch run from an `et` session must not stop the server carrying that
  # session. The session drops, the switch's output pipe breaks, and
  # switch-to-configuration panics (exit 101) part way through, leaving units such
  # as k3s stopped. The new etserver is picked up on the next reboot, or by hand
  # with `systemctl restart eternal-terminal` from a plain ssh session.
  systemd.services.eternal-terminal.restartIfChanged = false;
}
