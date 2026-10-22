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
      specialArgs = { inherit inputs; };

      dev = import ./dev { inherit git-hooks agenix; };

      # A host names its accounts explicitly (`users = [ "boog" ]`); each name is a
      # folder under users/ (or a path, for the fork check). Linux hosts also always
      # get root.
      userModules = names: map (u: if builtins.isPath u then u else ./users/${u}) names;

      # Per-platform nixpkgs flavour. Everything per-system (nixpkgs config,
      # devShells, checks, formatter, packages) is derived from this table.
      systems = {
        x86_64-linux = {
          nixpkgs = pkgs-stable;
          overlays = [
            (_: prev: {
              nodejs = prev.nodejs_22;
            })
          ];
        };
        aarch64-darwin = {
          nixpkgs = pkgs-darwin;
          overlays = [
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
      };
      forEachSystem = f: pkgs-stable.lib.mapAttrs f systems;

      mkNixpkgsConfig = system: {
        nixpkgs.config = {
          allowUnfree = true;
          allowBroken = false;
        };
        nixpkgs.overlays = systems.${system}.overlays;
      };

      # Roles (modules/server, modules/wsl) supply the host-class modules; what
      # every linux host shares is in modules/linux-common.nix.
      mkLinuxHost =
        name:
        {
          role,
          users,
          host ? ./hosts/${name},
          extraModules ? [ ],
        }:
        pkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            (mkNixpkgsConfig "x86_64-linux")
            agenix.nixosModules.default
            # Which commit built this generation (`nixos-version --configuration-revision`).
            # A dirty tree gets `<rev>-dirty`, so a local build that was never committed
            # is recognisable. The revision is part of the system derivation, so every
            # commit produces a new generation even when nothing else changed.
            { system.configurationRevision = self.rev or self.dirtyRev or null; }
          ]
          ++ [
            ./modules/linux-common.nix
            home-manager.nixosModules.home-manager
            vscode-server.nixosModule
          ]
          ++ extraModules
          ++ [ role ]
          ++ userModules users
          ++ [
            ./users/root
            host
          ];
        };

      # Fork acceptance check. Builds a server from nothing but a role, a made-up site
      # and a made-up user (tests/fork-example), and fails if any of my own values
      # leak into it. Evaluation is what is tested, so nothing heavy is built.
      forkExample = mkLinuxHost "example-node" {
        role = ./modules/server;
        users = [ ./tests/fork-example/user.nix ];
        host = ./tests/fork-example/host.nix;
      };
      forkExampleCheck =
        pkgs:
        let
          inherit (pkgs) lib;
          cfg = forkExample.config;
          myKeys = import ./secrets/keys.nix;
          checks = {
            "gateway comes from the site" = cfg.networking.defaultGateway.address == "192.168.1.1";
            "dns comes from the site" = cfg.networking.nameservers == [ "192.168.1.1" ];
            "node ip comes from the site" = cfg.k3sNode.ip == "192.168.1.50";
            "initrd keys come from the site" =
              lib.all (k: lib.hasInfix "AAAAexample" k) cfg.boot.initrd.network.ssh.authorizedKeys
              && !(lib.any (k: lib.hasInfix myKeys.nixosAdmin k) cfg.boot.initrd.network.ssh.authorizedKeys);
            "only the declared user is trusted" =
              lib.elem "example" cfg.nix.settings.trusted-users
              && !(lib.elem "boog" cfg.nix.settings.trusted-users);
            "my account is absent" = !(cfg.users.users ? boog) && !(cfg.age.secrets ? "passwords/users/boog");
          };
          failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);
        in
        assert lib.assertMsg (
          failed == [ ]
        ) "fork-example check failed: ${lib.concatStringsSep ", " failed}";
        pkgs.runCommand "fork-example" { } ''
          echo ${lib.escapeShellArg (builtins.unsafeDiscardStringContext cfg.system.build.toplevel.drvPath)} > $out
        '';
    in
    {
      nixosConfigurations = {
        sheol = mkLinuxHost "sheol" {
          role = ./modules/server;
          users = [ "boog" ];
        };
        abaddon = mkLinuxHost "abaddon" {
          role = ./modules/server;
          users = [ "boog" ];
        };
        gehenna = mkLinuxHost "gehenna" {
          users = [ "boog" ];
          extraModules = [ nixos-wsl.nixosModules.default ];
          role = ./modules/wsl;
        };
      };

      darwinConfigurations.boog-MBP = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;
        modules = [
          (mkNixpkgsConfig "aarch64-darwin")
          ./hosts/boog-MBP
        ]
        ++ userModules [ "darwin" ]
        ++ [
          home-manager.darwinModules.home-manager
          ./modules/nix-settings.nix
        ];
      };

      devShells = forEachSystem (
        system: s:
        let
          pkgs = import s.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            inherit (s) overlays;
          };
          toolsShell = dev.mkToolsShell pkgs;
        in
        {
          default = toolsShell;
          tools = toolsShell;
          nix-config = dev.mkDevShell system pkgs;
        }
      );

      # `nixos-rebuild` for deploying to sheol/abaddon from the Mac (see the
      # `nixos_remote` fish function). Pinned here so it matches the flake's nixpkgs
      # rather than whatever the `nixpkgs` registry entry points to.
      packages = forEachSystem (
        system: s: {
          nixos-rebuild = s.nixpkgs.legacyPackages.${system}.nixos-rebuild-ng;
        }
      );

      # `nix flake check` runs the hooks, the fork acceptance check and the secrets
      # consistency check; `nix fmt`
      # formats the repo.
      checks = forEachSystem (
        system: s:
        {
          pre-commit = dev.mkHooks system;
          secrets-consistency = import ./dev/secrets-check.nix { pkgs = s.nixpkgs.legacyPackages.${system}; };
        }
        // pkgs-stable.lib.optionalAttrs (system == "x86_64-linux") {
          fork-example = forkExampleCheck s.nixpkgs.legacyPackages.${system};
        }
      );
      formatter = forEachSystem (system: s: s.nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
