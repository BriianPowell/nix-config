# Plan: multi-user and fork-friendly configuration

Status: **phases 0 to 5, S1, the secrets cleanup (S1b), S2 and S3 are done** (S3 has not
run on GitHub yet). Open: the backlog. The module
export is deferred ([#21](https://github.com/BriianPowell/nix-config/issues/21)).
The sections below keep the original reasoning; where a name changed during
implementation, the current name is used. For how to *use* the result, see
`README.md` ("Using this repo"), `docs/HOME-MANAGER.md` and `docs/SECRETS.md`.

## Goal

Someone should be able to fork this repo, add a host and a user of their own, fill
in their own environment values, and get a working configuration in which **none of
my accounts, keys, secrets or network values apply to their machines**. My hosts
must keep working unchanged in the same flake.

Principles:

- Extend the current structure; do not replace it.
- Shared modules are generic: no personal defaults.
- Values come from the `users/` folders (identity, per-user files) and a small
  `site` layer (network, admin keys).
- Hosts declare which users and which site they use. Nothing is applied to every
  host implicitly.
- Prefer the smallest change that closes a leak.

Already done: git identity comes from `users/common/git.nix`, not the `git`
module (see the git-identity PR).

## Inspiration, and what is deliberately not adopted

Reference: [dudeofawesome/nix-config](https://github.com/dudeofawesome/nix-config),
a multi-machine, multi-user flake. Reviewed in part (flake, host registry, host
builder, users module, home-manager glue); the configurable modules, machine
classes and sops layout were not read.

Borrowed, in its smallest form:

- **A host picks its users** (`users = [ "boog" ]`) instead of every host getting
  them. This closes the biggest leak.
- **A user folder owns everything about that user**: account details, their
  secrets, their home-manager config. Mostly a tidy-up of what exists.
- **Secrets declared next to their owner** (we keep agenix; only the location
  moves).
- **Optional later:** exporting the modules as flake outputs
  (`nixosModules.default`, `homeModules.default`) so someone can consume them as
  an input instead of forking.

Not adopted, because the current repo is simpler and better here:

- Machine classes and an `owner` field (the `modules/server` and `modules/wsl` roles are enough).
- The `{ os, user, home-manager }` user record and a hand-maintained user registry
  (keep `users/<name>/default.nix` importing its pieces).
- A large `specialArgs` bag passed to every module, `try-import` (silently ignores
  missing files), absolute personal paths in the flake, sops-nix, and the extra
  inputs.

Kept as-is: the `enable`-flag home-manager modules, the role modules (`modules/server`, `modules/wsl`),
`mkLinuxHost` and the `systems` table, the short input list, derivation-based
verification and the git hooks.

## Where my values leaked into every host (before this work)

| # | Leak | Where | Effect on a forked host |
| --- | --- | --- | --- |
| 1 | Global user modules | a global user list (`boog`, `root`) applied by `mkLinuxHost` in `flake.nix` (was `suites.userModules`) | New host creates my account, password secret and authorized keys |
| 2 | Initrd admin key | `modules/server/boot.nix` imports a key from `secrets/keys.nix` | Their unlock prompt would authorize my key |
| 3 | LAN values | `modules/server/base.nix` (gateway, DNS, fallback DNS, firewall ports); `hosts/abaddon/*` (node IP, k3s server address, DNS) | Wrong network config |
| 4 | Secrets | `modules/secrets.nix` defines `boog`, `root` and k3s token for every Linux host; `secrets/agenix-rules.nix` recipients are my keys | Builds, then fails at activation (cannot decrypt) |
| 5 | Name mismatches | Mac username: `users/darwin/default.nix` vs `machine.username` default; former `trustedUsers` default (now removed) | Confusing overrides |
| 6 | Personal files in shared modules | SSH client config, 1Password agent config, atuin server, GitHub deploy key (all moved to `users/` in phase 4); git signing key import, `users/darwin/*` | Enabling a module pulls my files |

## Target design

1. **Hosts choose users.** `mkLinuxHost` takes a `users` list and imports
   `users/<name>` for each. The global `userModules` goes away. `root` stays as a
   common base unless we decide otherwise (see open questions).
2. **A `site` layer.** A small module `modules/site.nix` with no defaults:
   `site.servers.{gateway,dns}`, `site.hosts.<name>.ip` and
   `site.initrdAuthorizedKeys` (keys allowed to unlock the initrd). My values live
   in `sites/home.nix`; each server host imports a site file.
   `server/base.nix` and `server/boot.nix` read from it. The reference repo does
   not cover this, so it is designed here.
3. **Secrets live with their owner.** The `boog` password and authorized-keys
   secrets move into `users/boog`; `root` into `users/root`; the k3s token
   is declared by `modules/server/k3s-node.nix` for hosts that set
   `k3sNode.tokenSecret`. A forker re-keys `secrets/agenix-rules.nix` to their own keys
   and replaces the `.age` files.
4. **Personal files stay under `users/<name>/`.** Shared home modules take paths
   or content through options with no personal defaults (default `null`/empty).
5. **One username source per platform.** `machine.username` and the home-manager
   user name derive from the same value; trusted users come from each user module (done).

## Phases

Each phase is its own branch and PR, verified before the next starts.

### Phase 0: land the git-identity branch

Commit and merge the staged git-identity change. Prerequisite for the rest.

### Phase 1: host-declared users

- Replace the global user list with a per-host `users` argument in `flake.nix`.
- Darwin gets the same treatment (`users/darwin` is a user folder named after the
  platform; consider renaming it, see open questions).
- Done on the way: `suites.nix` removed (roles are `modules/server` and
  `modules/wsl`), and trusted users come from each `users/*` module instead of a
  hard-coded option.
- Expected result: **identical derivations** for all hosts.

### Phase 1b: tidy the user lists (changes derivations)

Follow-up to phase 1, kept separate because it is the first step that is *not* a
pure refactor. Sheol and abaddon currently evaluate
`nix.settings.trusted-users` as `["root" "boog" "root"]`: NixOS already trusts
`root` by default, so `users/root` adding it again is redundant.

- Drop `nix.settings.trusted-users = [ "root" ]` from `users/root/default.nix`.
- Check the evaluated list is `["root" "boog"]` on the servers and unchanged on
  darwin.
- Expected result: **different derivations** for sheol, abaddon and gehenna (only
  `nix.conf` changes). Re-baseline the fingerprints, then deploy sheol and abaddon
  with `nixos_remote`. The nix daemon reloads its config on switch; no reboot and
  no k3s restart is expected, but confirm both nodes stay Ready.

### Phase 2: site layer

Status: done. The site is `site.servers.{gateway,dns}`, `site.hosts.<name>.ip` and
`site.initrdAuthorizedKeys`; node IPs and the k3s server address are read from it.

- Add `modules/site.nix` and `sites/home.nix`; hosts import the site file.
- Move gateway, DNS, fallback DNS and the initrd admin keys out of the shared
  server modules.
- Expected result: **identical derivations** (same values, different source).
  Because the initrd derivation is unchanged, no reboot test is needed if the
  comparison is identical.

### Phase 3: secrets ownership

Status: done. User secrets live in `users/*`; `modules/secrets.nix` is gone. This
step was not derivation-identical: sheol stopped decrypting the k3s token. That was
reversed in S1b, which pins the token on both nodes (`k3sNode.tokenSecret` in
`modules/server/k3s-node.nix`). Documented in `docs/SECRETS.md`.

- Move `age.secrets` definitions next to the user or role that uses them.
- Document re-keying in `docs/` (recipients, regenerating the `.age` files,
  initrd host keys under `/etc/secrets/initrd`).
- Expected result: identical derivations.

### Phase 4: personal files out of shared modules

Status: done, with one deliberate difference from "identical derivations".

- `ssh.configFile` and `tooling.onePasswordAgentConfig` are options with a `null`
  default; `users/boog` and `users/darwin` supply their own files
  (`users/*/ssh.config`, `users/darwin/1password-agent.toml`).
- The atuin sync server is set from `users/common/atuin.nix`, not in the module.
- The per-host GitHub deploy key moved from `modules/openssh.nix` to
  `users/boog/github-deploy-key.nix`.
- `machine.username` no longer defaults to `boog`.
- Because the SSH and agent files now come from `users/` instead of a copied
  `home/ssh/` directory, their store paths change, so the home-manager derivations
  change on sheol, abaddon, gehenna and the Mac. File contents are identical
  (git reports 100% renames); `nix-diff` shows only the source path differing.

- SSH client config, 1Password agent file, signing key import, Mac app settings:
  options with empty defaults, values supplied from `users/<name>/`.
- Expected result: identical derivations for my hosts.

### Phase 5: consistency and docs

Status: done.

- The Mac account name is written once, in `users/darwin/machine.nix`;
  `users/darwin/default.nix` derives the home-manager user, the system user, the
  home directory and the trusted-user entry from `machine.username`.
- `README.md` has a "Using this repo" section.
- The fork acceptance check is `checks.x86_64-linux.fork-example` (a made-up site,
  user and host under `tests/fork-example`). It fails if my gateway, DNS, node IP,
  initrd key, account or secrets show up in it. I confirmed it fails when a trusted
  user is hard-coded in a shared module and when a site has no entry for the host.

- Single username source per platform; trusted users set by each user module (done).
- Add a "Using this repo" section to `README.md`: add a host, add a user, write a
  site file, re-key secrets, generate initrd host keys.

### Optional: export modules as flake outputs

Status: deferred until someone else consumes the repo; tracked in
[#21](https://github.com/BriianPowell/nix-config/issues/21).

- Expose `nixosModules.default` and `homeModules.default` so another repo can
  consume the generic modules as a flake input instead of forking. Decide after
  phase 4, once the modules are known to be free of personal defaults.

## Stretch goals

These are enhancements, not requirements for fork support. The first three are
real phases (cheap, and they make the core phases safer); the rest is a backlog.
Phases S1 and S2 can run any time, including before phase 1.

### Phase S1: label generations with their git commit

Status: done (NixOS hosts only; the Mac is rebuilt locally from a dirty tree most of
the time, so a label adds little there). Verified: servers and gehenna `etc` are
identical once the revision is forced to `null`; the only other difference is the
`nixos-version` script, which now embeds the revision. Comparison scripts must force
`system.configurationRevision = null` (see Verification).

- Set `system.configurationRevision` from the flake revision, so
  `nixos-version --configuration-revision` (and `--json`) show which commit a
  generation came from. The boot menu entry names are unchanged.
- **This intentionally changes the system derivations** (the revision is part of
  them). Land it in its own PR, and exclude it from the fingerprint comparison
  when verifying other phases (or re-baseline after it merges).
- Dirty trees get a distinct marker, so an undeployed local build is visible.

### Phase S1b: secrets cleanup

Status: done and deployed to both servers.

- **One admin recipient.** `secrets/agenix-rules.nix` encrypts to the hosts plus
  `keys.nixosAdmin` only. Two unlabelled 2023 personal keys and the git signing key
  were removed, and all six `.age` files were re-keyed (checked by reading the
  recipient tags in each file header). The signing key stays in `keys.nix` for
  commit signing; signing and decrypting are separate keys.
- **Pinned k3s token.** The token is the plain secret (no `K10...::server:` prefix),
  read by both nodes through `k3sNode.tokenSecret`, so wiping sheol's data directory
  no longer breaks abaddon's join. Verified before the change that the file held the
  same secret sheol was running (matching hashes), because sheol runs embedded etcd,
  which encrypts its bootstrap data with the token. Abaddon's derivation did not
  change; sheol's did, by the secret and `--token-file`.
- **Tooling.** `agenix` (the flake's pinned version) and `AGENIX_RULES` are in the
  `nix-config` dev shell (the rules file is `secrets/agenix-rules.nix`, the name newer
  agenix expects, instead of the deprecated `secrets.nix` discovery and `RULES`); `programs.direnv` loads it on the Mac; the dead
  `secrets/ssh/initrd-login.nix` is gone. The `encrypt.sh` scripts, `_tools.sh` and
  `recipients.nix` were removed afterwards: `agenix -e <file>` with piped input
  encrypts to that file's recipients in `agenix-rules.nix`, which is all they did.
- **Docs.** `secrets/ssh/README.md` is now a runbook for the SSH material only, and
  `docs/SECRETS.md` covers recipients, adding users and hosts, and re-keying.
- `~/.cursorignore` is managed from `users/darwin/cursorignore` and hides only
  `*.age`, so agents can read the public secrets files.

### Phase S2: safer deploys with `nixos_remote`

Status: done in the repo; installed with the next Mac switch. No effect on system
derivations. The probe and the table logic were tested against a stubbed `ssh`
with canned output copied from sheol (healthy, pinned default, `test` deploy,
unreachable host); the remote script itself has not been run on a server yet.

- **`nixos_remote status [host...]`** prints installed, running, booted and
  boot-default generations, and whether the running kernel or initrd differs from
  the booted one. No sudo: it reads the world-readable EFI variables
  (`LoaderEntrySelected`, `LoaderEntryDefault`) and the system profile links.
- **After `switch` or `boot`, `nixos_remote` warns** when the default is pinned
  (`bootctl set-default`) to a generation other than the one just installed, and
  says when a reboot is needed to run a changed kernel or initrd.
- **The flake checkout is printed** (path and commit) before anything runs. The
  plan first said to resolve it from the repo containing the script, but the
  function is installed from the nix store and cannot find its repository; showing
  the path and the existing branch and dirty-tree warnings covers the same risk.
- The servers' login shell is fish, so remote probes go in over stdin to `sh -s`
  (`__nixos_remote_probe`), not as a command line.
- One file, `home/fish/functions/nixos_remote.fish`: `status` is an action, and the
  probe and verify helpers live in the same file, so nothing new is registered in
  `home/modules/fish.nix`.

### Phase S3: CI on pull requests

Status: done in the repo, **not yet run on GitHub**. The comparison script was run
locally (changed, identical, Linux and Mac, under bash 3.2, shellcheck clean) and the
workflow passes `actionlint`, but the first pull request will be its first real run.

- **`.github/workflows/ci.yml`**, actions pinned by commit SHA, `pull_request`
  trigger only (a fork's code never sees secrets):
  - `check`: `nix flake check` (pre-commit hooks, the fork acceptance check and an
    evaluation of every host).
  - `compare`: runs `scripts/derivation-fingerprint compare` against the base branch,
    Linux hosts on Linux and the Mac on macOS. The report goes to the job summary,
    and to a PR comment (updated in place) for PRs from this repository.
  - `closure`: the same with `--closure`, a closure diff of the Linux hosts, only
    when the PR carries the `closure-diff` label. It builds both sides, so it is slow
    and may need the cache; untested.
- **`scripts/derivation-fingerprint`** (`list` and `compare`) replaces the manual
  comparison scripts. It forces `system.configurationRevision = null`, explains each
  difference with nix-diff, and shows only the name of a changed `.age` file (nix-diff
  would print its ciphertext).
- **`nix flake check` needed a fix first.** `gehenna`'s toplevel failed NixOS's
  lockout assertion (no password or key on any account), so the check could never
  pass. The WSL role now sets `users.allowNoPasswordLogin = true`: a WSL guest is
  entered through `wsl.exe`, not a login prompt. Only gehenna's derivation changed.
- Not covered: the Mac build itself (the macOS job only evaluates), and applying any
  change to a real host.

### Backlog (no order, pick as needed)

Open items across the setup are tracked as
[`enhancement` issues](https://github.com/BriianPowell/nix-config/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement).

- **Generate SSH aliases from the site host list.** The plain host entries and
  the `*Initrd` aliases come from one list of hosts and addresses; the k3s server
  address and DNS entries read from the same place. Depends on phase 2.
- **Scaffolding for new hosts and users.** A script or flake template that
  creates the skeleton, initrd host keys, and the re-keying steps, turning the
  README guide into a command.
- **Generated secret recipients.** Derive `secrets/agenix-rules.nix` recipients from
  the hosts and users. Depends on phase 3.
- **Generated option docs** with `nixosOptionsDoc`, so forkers can browse every
  option.
- **Flake lock automation** (Renovate or Dependabot), gated by the CI check.
- **Standalone home-manager outputs** (`user@host`) for machines that are not
  NixOS or nix-darwin.
- **Disko disk layouts.** A shared layout module would replace `server.disks.*`
  and `server.luksUuid` and make reinstalls one command. Tracked on the disko
  branch; revisit the server hardware and boot modules when it lands.
- **NixOS VM test for the remote LUKS unlock**, so the initrd SSH path is tested
  without real hardware.
- **Health checks and alerting** (k3s Ready, ZFS pool state). Belongs in the
  `k3s-collective` monitoring stack, not this repo; recorded here so it is not
  lost.
- **More architectures** (aarch64, Raspberry Pi) in `mkLinuxHost`.
- **Finish `gehenna`.** Not installed yet; the checklist (host key, secrets
  recipient, first real build) is a TODO comment in `hosts/gehenna/default.nix`.
  Ignored until the machine exists.
- **A Cursor module for the Mac** (`home/modules/cursor.nix`): the ignore file,
  keybindings and `argv.json`, not extensions or `mcp.json`.

## Verification

- **Fingerprint comparison** on every phase: evaluated system derivations for
  `abaddon`, `sheol`, `gehenna` and `boog-MBP`. Identical derivations mean no deploy
  risk. Any difference gets diffed and explained before merging.
  `scripts/derivation-fingerprint compare <base-checkout> .` does this (CI runs it on
  every PR); it forces `system.configurationRevision = null` so the commit label does
  not count as a difference.
- **Fork acceptance check.** Add a minimal example host that must evaluate with a
  dummy user and dummy site, and assert that it contains no `boog` account, no
  authorized key from my files, and none of my network values. This guards
  against regressions of the leaks above. Wire it into `checks` so
  `nix flake check` runs it.
- Pre-commit hooks pass on every phase.
- If any phase unexpectedly changes the initrd or user accounts on a real host,
  treat it as a reboot-test and console-fallback situation (see `INSTALL.md` and
  the generation notes in the repo history).

## Risks

- A mistake in the user or initrd-key moves could lock me out of a server.
  Mitigation: identical-derivation requirement, one phase at a time, console
  fallback to the previous generation.
- Secret ownership changes must not alter `age.secrets` paths or modes, or
  activation on the servers breaks.
- The repo is public. Keep values in this plan to structure and file names only.

## Out of scope (for now)

- Splitting into a generic repo plus a private repo of personal hosts. The
  optional module export covers the lighter version of this.
- The backlog items under "Stretch goals" until they are pulled into a phase.

## Decisions

- **Users are an explicit list per host** (`users = [ "boog" ]`). Nothing is
  discovered or applied implicitly.
- **`root` stays a base user on every host.** It holds nothing personal.
- **`users/darwin` keeps its name** (decided; the Mac account name is fixed by the machine, see `users/darwin/machine.nix`).
- **One site file per location** (`sites/home.nix`); a host imports the one that
  applies.
- **Secrets have one admin recipient** (`keys.nixosAdmin`, also the server login
  key). The git signing key is never a recipient.
- **The k3s token is pinned on both nodes**, as the plain secret, so it survives a
  wipe of the server.
- **The fork acceptance example host lives only in flake `checks`**, not as a real
  directory under `hosts/`.

## Open questions

- None open. The optional module exports are deferred to
  [#21](https://github.com/BriianPowell/nix-config/issues/21).
