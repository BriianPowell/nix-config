{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # Build Tools
    deno # https://deno.land/
    ruby # https://www.ruby-lang.org/en/
    # nodejs-16_x

    # Terminal Tools
    tmux # https://github.com/tmux/tmux
    fish # https://fishshell.com/
    git # https://git-scm.com/
    eternal-terminal # https://eternalterminal.dev/
    bat # https://github.com/sharkdp/bat
    lynx # https://lynx.invisible-island.net/
    most # https://www.jedsoft.org/most/index.html
    ncdu # https://dev.yorhel.nl/ncdu
    curl # https://curl.se/
    wget # https://www.gnu.org/software/wget/

    # System Monitoring
    htop # https://github.com/htop-dev/htop/
    bottom # https://github.com/ClementTsang/bottom
    bind # https://www.isc.org/bind/
    pciutils # https://mj.ucw.cz/sw/pciutils/

    jq # https://stedolan.github.io/jq/
    ripgrep # https://github.com/BurntSushi/ripgrep
  ];

  sound.enable = false;

  networking = {
    defaultGateway = "10.0.0.1";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
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

  time.timeZone = lib.mkDefault "America/Los_Angeles";

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
    fallbackDns = [ "1.0.0.1" "2606:4700:4700::1001" ];
  };

  services = {
    avahi.enable = false; # USE SYSTEMD-RESOLVED
    vscode-server.enable = true;
    eternal-terminal.enable = true;
  };
}
