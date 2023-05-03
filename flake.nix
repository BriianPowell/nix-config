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
    };

    agenix = {
      url = "github:ryantm/agenix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

    dotfiles = {
      url = "github:briianpowell/dotfiles";
      flake = false;
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs@{ self, nixpkgs, stable, unstable, utils, home-manager, agenix, vscode-server, dotfiles, nixos-hardware }:
    let
      suites = import ./suites.nix { inherit utils; inherit dotfiles; };
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
              #inherit (channel) stable;
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
          agenix.nixosModules.default
          vscode-server.nixosModule
        ] ++ suites.sharedModules;
      };

      hosts = {
        sheol = {
          channelName = "unstable";
          modules = suites.userModules ++ [ ./hosts/sheol ];
          specialArgs = { inherit dotfiles; };
        };
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
