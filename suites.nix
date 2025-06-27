{ utils, home-manager, dotfiles, defaultSpecialArgs }:
let
  nixosModules = utils.lib.exportModules [
    ./modules/base-server.nix
    ./modules/i18n.nix
    ./modules/minimal-docs.nix
    ./modules/openssh.nix
    ./modules/security.nix
    ./modules/tcp-hardening.nix
    ./modules/tcp-optimization.nix
    ./modules/cli.nix
    ./modules/secrets.nix
    ./modules/fonts.nix
    ./modules/shared-options.nix

    ./users/boog
    ./users/root
    ./users/darwin
  ];

  sharedModules = with nixosModules; [
    cli
    fonts
    secrets
    shared-options
  ];

  serverModules = with nixosModules; [
    base-server
    i18n
    minimal-docs
    openssh
    security
    tcp-hardening
    tcp-optimization
  ];

  sharedOptions = { dotfiles, config, ... }: {
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

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    nix.linkInputs = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = defaultSpecialArgs;
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
  inherit nixosModules sharedModules serverModules userModules darwinModules;
}
