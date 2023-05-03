{ utils, dotfiles }:
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
    ./modules/users.nix

    ./users/boog
    ./users/louis
    ./users/root
  ];
  sharedModules = with nixosModules; [
    base-server
    i18n
    minimal-docs
    openssh
    security
    tcp-hardening
    tcp-optimization

    #utils.nixosModules.saneFlakeDefaults
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];
  userModules = with nixosModules; [
    cli
    boog
    louis
    root

    ({ pkgs, lib, config, dotfiles, ... }: {
      nix.settings.trusted-users = [ "boog" ];
      nix.generateRegistryFromInputs = true;
      nix.linkInputs = true;
      #nix.generateNixPathFromInputs = true;
      home-manager.users.boog = import ./home;
      home-manager.extraSpecialArgs = {
        inherit dotfiles;
      };
      #boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_5_15;
      #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      nixpkgs.config.allowBroken = false;
      nix.extraOptions = ''
        http-connections = 50
        log-lines = 50
        warn-dirty = false
      '';
    })
  ];
in
{
  inherit nixosModules sharedModules userModules;
}
