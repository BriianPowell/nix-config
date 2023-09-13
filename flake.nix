{
  description = "BriianPowell's Nix Configurations";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "unstable";

    utils = {
      # url = "github:gytis-ivaskevicius/flake-utils-plus";
      url = "github:ravensiris/flake-utils-plus?ref=ravensiris/fix-devshell-legacy-packages";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server/hm-module-import";
    };

    dotfiles = {
      url = "github:briianpowell/dotfiles";
      flake = false;
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
    };
  };

  outputs = inputs@{ self, nixpkgs, stable, unstable, utils, home-manager, agenix, vscode-server, dotfiles, nixos-hardware, darwin }:
    let
      suites = import ./suites.nix { inherit utils; inherit home-manager; inherit dotfiles; };
    in
    with suites.nixosModules;
    utils.lib.mkFlake {
      inherit self inputs;
      inherit (suites) nixosModules;

      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      channelsConfig = {
        allowUnfree = true;
        allowBroken = false;
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

      hostDefaults = {
        system = "x86_64-linux";
        modules = [ agenix.nixosModules.default ] ++ suites.sharedModules;
        channelName = "unstable";
      };

      hosts = {
        sheol = {
          specialArgs = { inherit dotfiles; };
          modules = [ home-manager.nixosModules.home-manager vscode-server.nixosModule.default ./hosts/sheol ] ++ suites.serverModules ++ suites.userModules;
        };
        abaddon = {
          specialArgs = { inherit dotfiles; };
          modules = [ home-manager.nixosModules.home-manager vscode-server.nixosModule.default ./hosts/abaddon ] ++ suites.serverModules ++ suites.userModules;
        };
        boog-MBP = {
          system = "aarch64-darwin";
          specialArgs = { inherit dotfiles; };
          modules = [ ./hosts/boog-MBP ] ++ suites.darwinModules;
          output = "darwinConfigurations";
          builder = darwin.lib.darwinSystem;
        };
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
