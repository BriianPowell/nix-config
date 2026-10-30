# nix-config

Flake for NixOS (sheol, abaddon), NixOS-WSL (gehenna) and nix-darwin (boog-MBP).
Machine-wide context for the Mac (installed tools, Homebrew, local LLM) is generated
into `~/.claude/CLAUDE.md` and `~/.config/opencode/AGENTS.md` from
`home/modules/agents.nix`. This file covers only this repo. The repo is public.

## Layout

- `flake.nix`: host definitions, per-platform nixpkgs table, checks. `dev/`: dev
  shells, git hooks and the secrets-consistency check.
- `hosts/<host>/`: per-host config. Mac packages are in `hosts/boog-MBP/system.nix`,
  Homebrew in `hosts/boog-MBP/brew.nix`.
- `modules/`: NixOS modules. `modules/server/` is the k3s server role,
  `modules/wsl/` the WSL role; what every Linux host shares is
  `modules/linux-common.nix`.
- `sites/`: values for a location (addresses, hosts). Modules read `config.site.*`;
  they must not name a host or an address themselves.
- `home/modules/*.nix`: Home Manager modules, each one option namespace
  (`<app>.enable` plus overrides), imported from `home/default.nix`.
- `users/<name>/`: accounts. `users/common/home.nix` enables what every account
  shares; `users/darwin/` is the Mac account (the name stays `darwin` because the
  Mac account name is fixed by the machine).
- `secrets/`: agenix material. Never read, print or commit it; see
  `secrets/ssh/README.md`.
- `docs/`: install, secrets, multi-user plan. `scripts/`: helper scripts.

## Commands

- Mac: `sudo darwin-rebuild check --flake .#boog-MBP`, then `switch`.
- Servers, from the Mac: `nixos_remote status|check|test|switch|rollback <host>`
  (`nixos_remote --help`). `test` reverts by itself unless you confirm.
- Evaluate without switching: `nix eval .#nixosConfigurations.<host>.config...`.
- `nix flake check` runs the hooks, the fork-example check and the secrets check.
  Run `scripts/derivation-fingerprint compare` to see which hosts a change affects.
- Tools beyond git and agenix are not installed globally: use
  `nix shell nixpkgs#<pkg> -c <cmd>`. Format with `nix fmt`.

## Conventions

- Add an option namespace under `home/modules/` and enable it in a user's
  `home.nix`; do not set `programs.<app>` from user files.
- A shared module never names a host, address, user or key of mine. A fork must be
  able to use it; `tests/fork-example` fails the build if one leaks.
- `git add -N <new file>` before evaluating: flakes ignore untracked files.
- Host-only software stays in the host's own files.
- Comments explain why (workarounds, constraints), as the existing files do.
- Secrets: rules in `secrets/agenix-rules.nix`, one `.age` file per rule; the
  secrets check fails if they disagree.
- Do not commit or push. Edit and verify; the maintainer commits.
