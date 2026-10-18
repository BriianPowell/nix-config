# Shared module sets for NixOS and nix-darwin hosts.
{ home-manager, defaultSpecialArgs }:
let
  nixosModules = {
    base-server = import ./modules/server/base.nix;
    i18n = import ./modules/i18n.nix;
    minimal-docs = import ./modules/minimal-docs.nix;
    openssh = import ./modules/openssh.nix;
    security = import ./modules/security.nix;
    tcp-hardening = import ./modules/server/tcp-hardening.nix;
    tcp-optimization = import ./modules/server/tcp-optimization.nix;
    k3s-node = import ./modules/server/k3s-node.nix;
    server-boot = import ./modules/server/boot.nix;
    server-hardware = import ./modules/server/hardware.nix;
    cli = import ./modules/cli.nix;
    secrets = import ./modules/secrets.nix;
    fonts = import ./modules/fonts.nix;
    shared-options = import ./modules/shared-options.nix;
    linux-common = import ./modules/linux-common.nix;

    boog = import ./users/boog;
    root = import ./users/root;
    darwin = import ./users/darwin;
  };

  sharedModules = with nixosModules; [
    cli
    linux-common
    fonts
    secrets
    shared-options
  ];

  serverModules = with nixosModules; [
    base-server
    k3s-node
    i18n
    minimal-docs
    openssh
    security
    server-boot
    server-hardware
    tcp-hardening
    tcp-optimization
  ];

  # WSL manages its own networking, firewall and init; we only pull in the
  # locale/docs/ssh/security modules that make sense inside a WSL distro.
  wslModules = with nixosModules; [
    i18n
    minimal-docs
    openssh
    security
  ];

  sharedOptions =
    { config, ... }:
    {
      nix.settings = {
        trusted-users = config.trustedUsers;
        max-jobs = 4;
        cores = 0;
        sandbox = true;
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        experimental-features = [
          "nix-command"
        ];
        warn-dirty = false;
        keep-outputs = true;
        keep-derivations = true;
        http-connections = 50;
        log-lines = 50;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = defaultSpecialArgs;
        # Back up existing files before HM replaces them (e.g. iterm2 plist, git ignore).
        backupFileExtension = "backup";
      };
    };

  userModules = with nixosModules; [
    boog
    root
    sharedOptions
  ];

  darwinModules = with nixosModules; [
    darwin
    home-manager.darwinModules.home-manager
    sharedOptions
  ];
in
{
  inherit
    nixosModules
    sharedModules
    serverModules
    wslModules
    userModules
    darwinModules
    ;
}
