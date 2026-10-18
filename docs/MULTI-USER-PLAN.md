# Plan: multi-user and fork-friendly configuration

Status: draft. Nothing in this plan is implemented yet.

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

- Machine classes and an `owner` field (`suites.nix` roles are enough).
- The `{ os, user, home-manager }` user record and a hand-maintained user registry
  (keep `users/<name>/default.nix` importing its pieces).
- A large `specialArgs` bag passed to every module, `try-import` (silently ignores
  missing files), absolute personal paths in the flake, sops-nix, and the extra
  inputs.

Kept as-is: the `enable`-flag home-manager modules, the flat `suites.nix`,
`mkLinuxHost` and the `systems` table, the short input list, derivation-based
verification and the git hooks.

## Where my values leak into every host today

| # | Leak | Where | Effect on a forked host |
| --- | --- | --- | --- |
| 1 | Global user modules | `suites.userModules` (`boog`, `root`) applied by `mkLinuxHost` in `flake.nix` | New host creates my account, password secret and authorized keys |
| 2 | Initrd admin key | `modules/server/boot.nix` imports a key from `secrets/keys.nix` | Their unlock prompt would authorize my key |
| 3 | LAN values | `modules/server/base.nix` (gateway, DNS, fallback DNS, firewall ports); `hosts/abaddon/*` (node IP, k3s server address, DNS) | Wrong network config |
| 4 | Secrets | `modules/secrets.nix` defines `boog`, `root` and k3s token for every Linux host; `secrets/secrets.nix` recipients are my keys | Builds, then fails at activation (cannot decrypt) |
| 5 | Name mismatches | Mac username: `users/darwin/default.nix` vs `machine.username` default; `trustedUsers` default in `modules/shared-options.nix` | Confusing overrides |
| 6 | Personal files in shared modules | `home/ssh/*.config`, 1Password agent config, git signing key import, `users/darwin/*` | Enabling a module pulls my files |

## Target design

1. **Hosts choose users.** `mkLinuxHost` takes a `users` list and imports
   `users/<name>` for each. The global `userModules` goes away. `root` stays as a
   common base unless we decide otherwise (see open questions).
2. **A `site` layer.** A small module `modules/site.nix` with no defaults:
   `site.gateway`, `site.dns`, `site.adminKeys` (keys allowed to unlock the
   initrd). My values live in `sites/home.nix`; each host imports a site file.
   `server/base.nix` and `server/boot.nix` read from it. The reference repo does
   not cover this, so it is designed here.
3. **Secrets live with their owner.** The `boog` password and authorized-keys
   secrets move into `users/boog`; `root` into `users/root`; the k3s token into
   the k3s agent role (not every host). A forker re-keys `secrets/secrets.nix` to
   their own keys and replaces the `.age` files.
4. **Personal files stay under `users/<name>/`.** Shared home modules take paths
   or content through options with no personal defaults (default `null`/empty).
5. **One username source per platform.** `machine.username` and the home-manager
   user name derive from the same value; `trustedUsers` derives from the host's
   users.

## Phases

Each phase is its own branch and PR, verified before the next starts.

### Phase 0: land the git-identity branch

Commit and merge the staged git-identity change. Prerequisite for the rest.

### Phase 1: host-declared users

- Replace `suites.userModules` with a per-host `users` argument in `flake.nix`.
- Darwin gets the same treatment (`users/darwin` is a user folder named after the
  platform; consider renaming it, see open questions).
- Expected result: **identical derivations** for all hosts.

### Phase 2: site layer

- Add `modules/site.nix` and `sites/home.nix`; hosts import the site file.
- Move gateway, DNS, fallback DNS and the initrd admin keys out of the shared
  server modules.
- Expected result: **identical derivations** (same values, different source).
  Because the initrd derivation is unchanged, no reboot test is needed if the
  comparison is identical.

### Phase 3: secrets ownership

- Move `age.secrets` definitions next to the user or role that uses them.
- Document re-keying in `docs/` (recipients, regenerating the `.age` files,
  initrd host keys under `/etc/secrets/initrd`).
- Expected result: identical derivations.

### Phase 4: personal files out of shared modules

- SSH client config, 1Password agent file, signing key import, Mac app settings:
  options with empty defaults, values supplied from `users/<name>/`.
- Expected result: identical derivations for my hosts.

### Phase 5: consistency and docs

- Single username source per platform; `trustedUsers` from host users.
- Add a "Using this repo" section to `README.md`: add a host, add a user, write a
  site file, re-key secrets, generate initrd host keys.

### Optional: export modules as flake outputs

- Expose `nixosModules.default` and `homeModules.default` so another repo can
  consume the generic modules as a flake input instead of forking. Decide after
  phase 4, once the modules are known to be free of personal defaults.

## Stretch goals

These are enhancements, not requirements for fork support. The first three are
real phases (cheap, and they make the core phases safer); the rest is a backlog.
Phases S1 and S2 can run any time, including before phase 1.

### Phase S1: label generations with their git commit

- Set `system.configurationRevision` from the flake revision, so
  `nixos-version --configuration-revision` and the boot menu show which commit a
  generation came from.
- **This intentionally changes the system derivations** (the revision is part of
  them). Land it in its own PR, and exclude it from the fingerprint comparison
  when verifying other phases (or re-baseline after it merges).
- Dirty trees get a distinct marker, so an undeployed local build is visible.

### Phase S2: safer deploys with `nixos_remote`

- After `boot` or `switch`, compare the boot default (`bootctl`) with the newly
  installed profile and warn when they differ (catches a pinned EFI default).
- Resolve the flake path from the repo containing the script, or fail clearly,
  instead of using whatever the current directory happens to be (catches
  deploying the wrong checkout).
- Add a `nixos_status` command that prints installed, booted and default
  generation for each host.
- Lives in `home/fish/functions/`; no effect on system derivations.

### Phase S3: CI on pull requests

- Run `nix flake check` (hooks, formats, and the fork acceptance check from the
  Verification section).
- Post the before/after derivation comparison and a closure diff as a PR
  comment, replacing the manual comparison script.
- Depends on the example host from the fork acceptance check; best done after
  phase 2.

### Backlog (no order, pick as needed)

- **Generate SSH aliases from the site host list.** The plain host entries and
  the `*Initrd` aliases come from one list of hosts and addresses; the k3s server
  address and DNS entries read from the same place. Depends on phase 2.
- **Scaffolding for new hosts and users.** A script or flake template that
  creates the skeleton, initrd host keys, and the re-keying steps, turning the
  README guide into a command.
- **Generated secret recipients.** Derive `secrets/secrets.nix` recipients from
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

## Verification

- **Fingerprint comparison** on every phase: evaluated system derivations for
  `abaddon`, `sheol`, `gehenna` (etc and system-path), `boog-MBP`, plus devShells,
  formatters and `nixos-rebuild`. Identical derivations mean no deploy risk. Any
  difference gets diffed and explained before merging.
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
- **`users/darwin` is renamed later**, in its own small PR, not in phase 1.
- **The fork acceptance example host lives only in flake `checks`**, not as a real
  directory under `hosts/`.

## Open questions

- Site layer layout: one file per site (for example `sites/home.nix`), or one file
  with named sites? Recommendation: one file per site; revisit only if there are
  two separate networks.
- Do the optional module exports belong in this plan, or in a follow-up?
