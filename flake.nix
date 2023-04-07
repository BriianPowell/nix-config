{
  description = "BriianPowell's Nix Configurations";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";

    utils = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, stable, unstable, utils, home-manager, vscode-server, nixos-hardware }@inputs:
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

      channels = {
        stable = {
          input = stable;
        };
        unstable = {
          input = unstable;
          overlaysBuilder = channels: [
            (final: prev: {
              # inherit (channels) stable;
            })
          ];
        };
      };

      # sharedOverlays = [
      #   self.overlay
      # ];

      hostDefaults = {
        modules = [
          home-manager.nixosModules.home-manager
          vscode-server.nixosModule
        ] ++ suites.sharedModules;
      };

      hosts = {
        sheol.modules = suites.userModules ++ [ ./hosts/sheol ];
        abaddon.modules = [ ./hosts/abaddon ];
      };

      outputsBuilder = channels:
        let pkgs = channels.unstable; in
        {
          devShells = mkShell {
            buildInputs = [ git transcrypt ];
          };
        };
    };
}
