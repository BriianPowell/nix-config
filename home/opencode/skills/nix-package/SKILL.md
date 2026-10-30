---
name: nix-package
description: Add or remove a CLI tool or app on the macOS host boog-MBP through nix-darwin. Use when asked to install, add or remove software on this Mac, to decide between nixpkgs, Homebrew and the devShell, or to make a tool available to agents.
---

## Decide where it goes

- Needed only for one task: do not install it. Use
  `nix shell nixpkgs#<pkg> -c <cmd>`; the dev shells (`dev/default.nix`) are kept small.
- Needed by the repo's own checks or hooks: add it to `dev/default.nix`.
- A CLI tool for everyday use: `environment.systemPackages` in
  `hosts/boog-MBP/system.nix`.
- A GUI app, or something nixpkgs cannot provide or ships broken: `hosts/boog-MBP/brew.nix`
  (`baseCasks` / `baseBrews`). Homebrew cleanup is `zap`, so anything not listed there is
  removed on rebuild.
- Needs a newer version than the stable channel: take it from `pkgs-unstable` in the
  `aarch64-darwin` overlay in `flake.nix`, as `mas`, `llama-cpp` and `opencode` are.
- Go, Terraform and Python versions come from `goenv`, `tfenv` and `pyenv`, not nix.

## Steps

1. Check the attribute exists in the channel the Mac uses:
   `nix eval --raw github:nixos/nixpkgs/nixpkgs-26.05-darwin#<attr>.name`
2. Add it to the right file, in its existing group, with a trailing comment linking the
   project page, like its neighbours.
3. New files must be visible to the flake: `git add -N <file>`.
4. Format: `nix fmt <file>` from the config repo.
5. Verify the config still evaluates:
   `nix eval --raw .#darwinConfigurations.boog-MBP.config.environment.systemPackages --apply 'ps: builtins.concatStringsSep "\n" (map (p: p.name or "?") ps)'`
   and look for the new package. For stronger checking use
   `sudo darwin-rebuild check --flake .#boog-MBP` and ask the user to run it.
6. Do not run `darwin-rebuild switch` or commit. Tell the user what to run.
