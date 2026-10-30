# nix-config

Declarative system and home configurations for NixOS (sheol, abaddon), NixOS-WSL (gehenna), and nix-darwin (boog-MBP). The repo is public; secrets use agenix.

**New machine?** See [docs/INSTALL.md](docs/INSTALL.md).  
**Forking?** See [docs/MULTI-USER-PLAN.md](docs/MULTI-USER-PLAN.md) and [README.md](README.md#using-this-repo).

## Repository Structure

```
flake.nix              # Host definitions, per-platform nixpkgs, checks, devShells
hosts/<host>/          # Per-host config (disk UUIDs, NICs, site imports)
  └─ boog-MBP/         # macOS: Homebrew, dock, machine-level settings
modules/               # Shared NixOS roles and common config
  ├─ linux-common.nix  # Base config for all Linux hosts
  ├─ server/           # k3s cluster role (sheol, abaddon)
  ├─ wsl/              # WSL role (gehenna)
  └─ site.nix          # Network layer (gateway, DNS, initrd keys)
sites/                 # Location values (addresses, admin keys)
  └─ home.nix          # My home network config
home/                  # Home Manager modules (option namespaces)
  ├─ modules/          # One namespace per app (fish, git, iter2, etc.)
  └─ default.nix       # Imports all modules; enabled via `<app>.enable`
users/                 # User accounts and personal config
  ├─ <name>/           # Per-user: account, secrets, home-manager hooks
  ├─ common/           # Shared across all accounts
  └─ root/             # Root account on Linux hosts
secrets/               # agenix-encrypted files (SSH keys, passwords)
docs/                  # Installation, Home Manager, secrets runbooks
tests/                 # Fork acceptance test (tests/fork-example)
dev/                   # Dev shells, pre-commit hooks, secrets check
scripts/               # Helper scripts (derivation-fingerprint comparison)
```

## How Configuration Flows

### Linux Hosts (NixOS)
```
flake.nix (mkLinuxHost)
  → modules/linux-common.nix (shared base)
  → modules/server or modules/wsl (role)
  → users/<name>/default.nix (per-user, one per host)
  → users/root (always included)
  → hosts/<host>/ (machine-specific)
  → site.nix imported by host (network values)
```

### macOS (nix-darwin)
```
flake.nix (darwinConfigurations.boog-MBP)
  → hosts/boog-MBP (machine config)
  → users/darwin (per-user, Mac account named "darwin")
  → home-manager (dotfiles via home/modules/*)
```

### Home Manager Modules
```
home/modules/*.nix     # Defines option namespace (e.g., fish.enable, fish.prompts)
users/common/home.nix  # Enables shared modules for all accounts
users/<name>/home.nix  # Per-user overrides and personal values
```

**Convention:** One top-level option namespace per app. Accounts set `enable` flags and per-user values; modules keep `programs.*` internal.

## Build, Test, Format

### Pre-commit Hooks
`nix flake check` runs:
- **pre-commit**: nixfmt, statix, deadnix, shellcheck (configured in `.pre-commit-config.yaml`)
- **fork-example**: Builds a dummy host from scratch; fails if personal values leak
- **secrets-consistency**: Validates agenix rules match declared secrets

### Checking Changes (No Build/Deploy)
```bash
# Evaluate all hosts
nix flake check

# Compare derivations against a baseline
git worktree add /tmp/base main
scripts/derivation-fingerprint compare /tmp/base .
git worktree remove /tmp/base
```

### Format
```bash
nix fmt  # Uses nixfmt (rnix/nixfmt-classic)
```

### Deploy
```bash
# macOS
sudo darwin-rebuild switch --flake .#boog-MBP

# Linux servers (from Mac)
nixos_remote status|check|test|switch <host>  # nixos_remote --help

# WSL
sudo nixos-rebuild switch --flake .#gehenna
```

## Key Modules and Relationships

### Server Role (`modules/server/`)
- **k3s-node.nix**: Kubernetes node config, token secret handling
- **boot.nix**: Initrd SSH unlock (reads `site.initrdAuthorizedKeys`)
- **base.nix**: Base services (reads `site.servers.{gateway,dns}`)

### Site Layer (`modules/site.nix`)
No defaults—must be provided by each host:
- `site.servers.gateway`, `site.servers.dns`: Network infrastructure
- `site.hosts.<name>.ip`: Per-host IP assignments
- `site.initrdAuthorizedKeys`: SSH keys allowed to unlock LUKS

### Secrets (`secrets/`)
- Declared next to owner (user module or role)
- `secrets/keys.nix`: Public keys (host keys, admin key)
- `secrets/agenix-rules.nix`: Who can decrypt each `.age` file
- **One admin recipient**: `keys.nixosAdmin` (server login key)
- Git signing key is deliberately NOT a recipient

## Conventions

1. **Hosts declare users**: `users = [ "boog" ]` in `flake.nix`. No global user list.
2. **Shared modules are generic**: No personal defaults, no hardcoded values.
3. **Personal values in `users/<name>/`**: Identity, configs, secrets stay per-user.
4. **Site values in `sites/`**: Network config is location-specific, not host-specific.
5. **Option namespaces**: Each `home/modules/*` defines one namespace (`<app>.enable`).
6. **Comments explain why**: Workarounds, constraints, design decisions.
7. **Fork-first design**: A fork replaces `sites/`, `users/`, `secrets/`—never edits `modules/`.

## What NOT to Touch

- **`secrets/*.age`**: Never read, print, log, or commit these. Use `agenix -e` to edit.
- **Personal values in shared modules**: If you see `boog`, a specific IP, or a personal path in `modules/` or `home/modules/`, that's a bug.
- **Committing without checking**: Always run `nix flake check` before pushing.
- **Pushing to main**: The repo is public; the maintainer handles commits.

## Development Workflow

1. **Add a host**: Create `hosts/<name>/`, import a site, add to `flake.nix` with role and users
2. **Add a user**: Create `users/<name>/`, follow [docs/HOME-MANAGER.md](docs/HOME-MANAGER.md)
3. **Add a site**: Copy `sites/home.nix`, fill network values, import from host
4. **Change secrets**: Edit `secrets/keys.nix` or `agenix-rules.nix`, then `cd secrets && agenix -r`
5. **Test locally**: `nix flake check` and `scripts/derivation-fingerprint compare`
6. **Deploy**: Use `nixos_remote` for servers, `darwin-rebuild` for Mac

## Code Graph

`graphify-out/` contains a code graph (204 nodes, 33 communities). Run:
- `graphify query "<question>"` for semantic questions
- `graphify update .` after code changes (offline, no LLM needed)

## Documentation

| File | Purpose |
|------|---------|
| [README.md](README.md) | Commands, using this repo, attribution |
| [docs/INSTALL.md](docs/INSTALL.md) | First-time setup for all hosts |
| [docs/HOME-MANAGER.md](docs/HOME-MANAGER.md) | Home Manager layout, adding accounts |
| [docs/SECRETS.md](docs/SECRETS.md) | Secret locations, re-keying, agenix |
| [docs/MULTI-USER-PLAN.md](docs/MULTI-USER-PLAN.md) | Fork-friendly architecture, phases |
| [secrets/ssh/README.md](secrets/ssh/README.md) | SSH runbook (login keys, deploy keys) |
| [hosts/boog-MBP/README.md](hosts/boog-MBP/README.md) | macOS layout, syncing defaults |

## Local LLM

This repo includes extensive local LLM setup guides (the largest documentation community). See `LLM_Setup_Guide.md` for Ollama, llama.cpp, MLX, llama-swap, and OpenCode integration.
