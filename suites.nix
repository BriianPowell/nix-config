{ utils, home-manager, dotfiles }:
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

    ./users/boog
    ./users/root
    ./users/darwin
  ];

  sharedModules = with nixosModules; [
    cli
    fonts
    secrets
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

  userModules = with nixosModules; [
    boog
    root

    ({ pkgs, lib, config, dotfiles, ... }: {
      nix.settings.trusted-users = [ "boog" ];
      # nix.generateRegistryFromInputs = true;
      nix.linkInputs = true;
      nix.generateNixPathFromInputs = true;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit dotfiles;
      };
      home-manager.users.boog = import ./home;
      #boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_5_15;
      #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      nix.extraOptions = ''
        http-connections = 50
        log-lines = 50
        warn-dirty = false
      '';
    })
  ];

  darwinModules = with nixosModules; [
    darwin

    home-manager.darwinModules.home-manager
    {
      nix.settings.trusted-users = [ "boog" ];
      # nix.generateRegistryFromInputs = true;
      nix.linkInputs = true;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit dotfiles; }; # Pass flake variable
      home-manager.users.boog = import ./home;
      nix.extraOptions = ''
        http-connections = 50
        log-lines = 50
        warn-dirty = false
      '';
    }
  ];
in
{
  inherit nixosModules sharedModules serverModules userModules darwinModules;
}
