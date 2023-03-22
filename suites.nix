{ utils }:
let
  nixosModules = utils.lib.exportModules [
    ./modules/base-server.nix
    ./modules/i18n.nix
    ./modules/minimal-docs.nix
    ./modules/openssh.nix
    ./modules/security.nix
    ./modules/tcp-hardening.nix
    ./modules/tcp-optimization.nix
    ./modules/users.nix
  ];
  sharedModules = with nixosModules; [
    base-server
    i18n
    minimal-docs
    openssh
    security
    tcp-hardening
    tcp-optimization
    users

    #utils.nixosModules.saneFlakeDefaults
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];
  # desktopModules = with nixosModules; [
  #   base-desktop
  #   cli
  #   cli-extras
  #   #./hosts/work/i3
  #   sway
  #   ({ pkgs, lib, config, ... }: {
  #     nix.generateRegistryFromInputs = true;
  #     nix.linkInputs = true;
  #     #nix.generateNixPathFromInputs = true;
  #     home-manager.users.gytis = import ./home-manager/sway.nix;
  #     boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_5_15;
  #     #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  #     #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  #     nixpkgs.config.allowBroken = false;
  #     hardware.bluetooth.enable = true;
  #     nix.extraOptions = ''
  #       http-connections = 50
  #       log-lines = 50
  #       warn-dirty = false
  #       http2 = true
  #       allow-import-from-derivation = true
  #     '';
  #   })
  # ];
in
{
  inherit nixosModules sharedModules; # desktopModules;
}
