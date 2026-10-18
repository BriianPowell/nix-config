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

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
      git-hooks,
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

      # Pre-commit hooks. The devShell installs them into .git/hooks (so direnv sets
      # them up on first load) and `nix flake check` runs the same checks.
      mkHooks =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            deadnix = {
              enable = true;
              # Module headers like `{ config, lib, ... }:` are kept uniform across
              # files, so unused arguments are not worth failing a commit over.
              settings = {
                noLambdaArg = true;
                noLambdaPatternNames = true;
              };
            };
            detect-private-keys.enable = true;
            ripsecrets = {
              enable = true;
              # The exported iTerm2 preferences hold base64 colour-space blobs that
              # look like secrets.
              excludes = [ "^home/iterm2/" ];
            };
            statix = {
              enable = true;
              settings = {
                config = "${./statix.toml}";
                # .direnv holds whole flake inputs, which statix would otherwise walk.
                ignore = [ ".direnv" ];
              };
            };
            check-merge-conflicts.enable = true;
          };
        };

      # mkShellNoCC: a C toolchain would export CC/AR/SDKROOT/DEVELOPER_DIR into every
      # repo that loads this shell through direnv, which can interfere with Xcode and
      # Homebrew builds. Nothing here needs a compiler.
      mkDevShell =
        system: pkgs:
        let
          hooks = mkHooks system;
        in
        pkgs.mkShellNoCC {
          name = "devShell";
          packages =
            with pkgs;
            [
              git
              transcrypt
            ]
            ++ hooks.enabledPackages;
          inherit (hooks) shellHook;
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

      devShells.x86_64-linux.default = mkDevShell "x86_64-linux" (
        import pkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = linuxNixpkgsConfig.nixpkgs.overlays;
        }
      );

      devShells.aarch64-darwin.default = mkDevShell "aarch64-darwin" (
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

      # `nix flake check` runs the hooks; `nix fmt` formats the repo.
      checks.x86_64-linux.pre-commit = mkHooks "x86_64-linux";
      checks.aarch64-darwin.pre-commit = mkHooks "aarch64-darwin";
      formatter.x86_64-linux = pkgs-stable.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-darwin = pkgs-darwin.legacyPackages.aarch64-darwin.nixfmt;
    };
}
