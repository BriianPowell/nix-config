{
  description = "BriianPowell's Nix Configurations";

  inputs =
    {
      stable.url = "github:nixos/nixpkgs/nixos-24.11";
      unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs.follows = "stable";

      utils = {
        url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
      };

      home-manager = {
        url = "github:nix-community/home-manager/release-24.11"; # "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      agenix = {
        url = "github:ryantm/agenix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      vscode-server = {
        url = "github:nix-community/nixos-vscode-server";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      dotfiles = {
        url = "github:briianpowell/dotfiles";
        flake = false;
      };

      darwin = {
        url = "github:lnl7/nix-darwin/nix-darwin-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      _1password-shell-plugins = {
        url = "github:1Password/shell-plugins";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs@{ self, nixpkgs, stable, unstable, utils, home-manager, agenix, vscode-server, dotfiles, darwin, ... }:
    let
      defaultSpecialArgs = { inherit dotfiles; };
      suites = import ./suites.nix {
        inherit utils home-manager dotfiles defaultSpecialArgs;
      };
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
          overlaysBuilder = channels: [
            (self: super: {
              nodejs = super.nodejs_22;
            })
          ];
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
        channelName = "stable";
      };

      hosts = {
        sheol = {
          specialArgs = defaultSpecialArgs;
          modules = [ home-manager.nixosModules.home-manager vscode-server.nixosModule ./hosts/sheol ] ++ suites.serverModules ++ suites.userModules;
        };
        abaddon = {
          specialArgs = defaultSpecialArgs;
          modules = [ home-manager.nixosModules.home-manager vscode-server.nixosModule ./hosts/abaddon ] ++ suites.serverModules ++ suites.userModules;
        };
        boog-MBP = {
          system = "aarch64-darwin";
          specialArgs = defaultSpecialArgs;
          modules = [ ./hosts/boog-MBP ] ++ suites.darwinModules;
          output = "darwinConfigurations";
          builder = darwin.lib.darwinSystem;
        };
      };

      outputsBuilder = channels: with channels.stable;
        {
          devShell = mkShell {
            name = "devShell";
            buildInputs = [ git transcrypt ];
          };
        };
    };
}
