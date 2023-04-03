{
  description = "Nix Configurations";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-22.11";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "latest";

    utils = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, latest, utils, home-manager, vscode-server, nixos-hardware }@inputs:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      mkApp = utils.lib.mkApp;
      suites = import ./suites.nix { inherit utils; };
    in
    with suites.nixosModules;
    utils.lib.mkFlake {
      inherit self inputs;
      inherit (suites) nixosModules;

      supportedSystems = [ "x86_64-linux" ];
      channelsConfig = {
        allowUnfree = true;
      };

      sharedOverlays = [
        self.overlay
      ];

      hostDefaults = {
        modules = [
          home-manager.nixosModule
          vscode-server.nixosModule
        ] ++ suites.sharedModules;
      };

      hosts = {
        sheol.modules = [ ./hosts/sheol ];
        abaddon.modules = [ ./hosts/abaddon ];
      };
    };
}
