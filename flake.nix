{
  description = "BriianPowell's Nix Configurations";

  inputs = {
    pkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    pkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    pkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "pkgs-stable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "pkgs-darwin";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      pkgs-stable,
      pkgs-darwin,
      pkgs-unstable,
      home-manager,
      agenix,
      vscode-server,
      darwin,
      nixos-wsl,
      ...
    }:
    let
      defaultSpecialArgs = {
        inherit inputs;
      };

      suites = import ./suites.nix {
        inherit home-manager defaultSpecialArgs;
      };

      linuxNixpkgsConfig = {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowBroken = false;
        nixpkgs.overlays = [
          (_: prev: {
            nodejs = prev.nodejs_22;
          })
        ];
      };

      darwinNixpkgsConfig = {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowBroken = false;
        nixpkgs.overlays = [
          (final: prev: {
            inherit
              (
                (import pkgs-unstable {
                  system = prev.stdenv.hostPlatform.system;
                  inherit (prev) config;
                })
              )
              mas
              ;
          })
        ];
      };

      linuxModules = [
        linuxNixpkgsConfig
        agenix.nixosModules.default
      ]
      ++ suites.sharedModules;

      mkLinuxHost =
        name: extraModules:
        pkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = defaultSpecialArgs;
          modules =
            linuxModules
            ++ extraModules
            ++ [
              ./hosts/${name}
            ];
        };

      mkDevShell =
        pkgs:
        pkgs.mkShell {
          name = "devShell";
          packages = with pkgs; [
            git
            transcrypt
          ];
        };
    in
    {
      nixosConfigurations = {
        sheol = mkLinuxHost "sheol" (
          [
            home-manager.nixosModules.home-manager
            vscode-server.nixosModule
          ]
          ++ suites.serverModules
          ++ suites.userModules
        );

        abaddon = mkLinuxHost "abaddon" (
          [
            home-manager.nixosModules.home-manager
            vscode-server.nixosModule
          ]
          ++ suites.serverModules
          ++ suites.userModules
        );

        gehenna = mkLinuxHost "gehenna" (
          [
            home-manager.nixosModules.home-manager
            vscode-server.nixosModule
            nixos-wsl.nixosModules.default
          ]
          ++ suites.wslModules
          ++ suites.userModules
        );
      };

      darwinConfigurations.boog-MBP = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = defaultSpecialArgs;
        modules = [
          darwinNixpkgsConfig
          ./hosts/boog-MBP
        ]
        ++ suites.darwinModules;
      };

      devShells.x86_64-linux.default = mkDevShell (
        import pkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = linuxNixpkgsConfig.nixpkgs.overlays;
        }
      );

      devShells.aarch64-darwin.default = mkDevShell (
        import pkgs-darwin {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          overlays = darwinNixpkgsConfig.nixpkgs.overlays;
        }
      );

      # `nixos-rebuild` for deploying to sheol/abaddon from the Mac (see the
      # `nixos_remote` fish function). Pinned here so it matches the flake's nixpkgs
      # rather than whatever the `nixpkgs` registry entry points to.
      packages.aarch64-darwin.nixos-rebuild = pkgs-darwin.legacyPackages.aarch64-darwin.nixos-rebuild-ng;
      packages.x86_64-linux.nixos-rebuild = pkgs-stable.legacyPackages.x86_64-linux.nixos-rebuild-ng;
    };
}
