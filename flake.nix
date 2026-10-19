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

      # A host names its accounts explicitly (`users = [ "boog" ]`); each name is a
      # folder under users/. Linux hosts also always get root.
      userModules = names: map (name: ./users/${name}) names;

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
          extraModules ? [ ],
        }:
        pkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            (mkNixpkgsConfig "x86_64-linux")
            agenix.nixosModules.default
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

      # This repo's own shell (`devShells.<system>.nix-config`, loaded by .envrc here). Its
      # git-hooks.nix shellHook symlinks .pre-commit-config.yaml and reinstalls every hook
      # into whichever git repo loads it, so it must not be the default that other repos pick up.
      #
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

      # The default shell, for every other repo that loads this flake through direnv
      # (k3s-collective, hass-config, grafana-dashboards, ...). Also available as `#tools`.
      # No nix hooks are installed. A repo that carries its own .pre-commit-config.yaml
      # gets exactly that config activated; anything else is left alone.
      mkToolsShell =
        pkgs:
        pkgs.mkShellNoCC {
          name = "tools";
          packages = with pkgs; [
            git
            transcrypt
            pre-commit
          ];
          # Install the repo's own hooks, only when all of these hold:
          #  - the config is a real file. A symlink is git-hooks.nix output (this repo's
          #    config, or one committed by mistake) and points into the nix store;
          #  - core.hooksPath is unset, which `pre-commit install` refuses to work with;
          #  - there is no pre-commit hook yet, or it is a pre-commit one. Another tool's
          #    hook (husky, a hand-written one) is never replaced;
          #  - the hook does not already point at this pre-commit build. The hook embeds
          #    store paths that a garbage collection can remove, so this also repairs
          #    those, and skips the install on every other load.
          # It never fails the shell: a failed install just prints a note.
          shellHook = ''
            if top=$(git rev-parse --show-toplevel 2>/dev/null); then
              cfg="$top/.pre-commit-config.yaml"
              hook="$(git rev-parse --path-format=absolute --git-common-dir)/hooks/pre-commit"
              if [ -f "$cfg" ] && [ ! -L "$cfg" ] \
                && [ -z "$(git config --get core.hooksPath)" ] \
                && { [ ! -e "$hook" ] || grep -q 'File generated by pre-commit' "$hook"; } \
                && ! grep -qF '${pkgs.pre-commit}/bin/pre-commit' "$hook" 2>/dev/null; then
                if (cd "$top" && ${pkgs.pre-commit}/bin/pre-commit install >/dev/null 2>&1); then
                  echo "pre-commit: installed hooks from $cfg" >&2
                else
                  echo "pre-commit: could not install hooks from $cfg" >&2
                fi
              fi
            fi
            unset top cfg hook
          '';
        };
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
          toolsShell = mkToolsShell pkgs;
        in
        {
          default = toolsShell;
          tools = toolsShell;
          nix-config = mkDevShell system pkgs;
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

      # `nix flake check` runs the hooks; `nix fmt` formats the repo.
      checks = forEachSystem (system: _: { pre-commit = mkHooks system; });
      formatter = forEachSystem (system: s: s.nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
