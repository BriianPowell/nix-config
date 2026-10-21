# SSH secrets (agenix)

Runbook for the SSH-related secrets. Concepts (who can decrypt, adding users and
hosts, re-keying) are in [`docs/SECRETS.md`](../../docs/SECRETS.md). Run every
command from the repo root.

| Secret | Plaintext input (gitignored) | Ends up on the host |
| --- | --- | --- |
| `authorized_keys/boog.age` | `authorized_keys/boog.plain`: public keys, one per line | `/home/boog/.ssh/authorized_keys`, written by an activation script |
| `github/sheol.age` | `github/sheol.plain`: private deploy key | `/home/boog/.ssh/github` |
| `github/abaddon.age` | `github/abaddon.plain`: private deploy key | `/home/boog/.ssh/github` |

Commit only `*.age` files; `*.plain` is in `.gitignore`.

The `encrypt.sh` scripts take their recipients from the matching rule in
`secrets/secrets.nix` and encrypt with `age -r <ssh-public-key>`, which is the
format agenix reads. `authorized_keys/recipients.nix` is used only by the
`authorized_keys` script, and it collects every key in `secrets.nix`. The scripts
need `nix` and network access the first time (they fetch `age` from nixpkgs).

## Update login keys

1. Put the public keys that may log in as `boog` in `authorized_keys/boog.plain`.
2. Encrypt:

   ```bash
   ./secrets/ssh/authorized_keys/encrypt.sh
   ```

3. Commit `boog.age`, then `nixos-rebuild switch` on sheol and abaddon.

The Mac's login key is the **NixOS Admin** item in 1Password (see
`users/darwin/ssh.config` and `users/darwin/1password-agent.toml`). Do not set
`IdentitiesOnly yes` without an `IdentityFile`, because that skips the 1Password
agent. Git signing uses `keys.gitSigning` (`users/darwin/git.nix`); keep the
Personal key, not NixOS Admin, in `agent.toml`.

## Initrd (LUKS unlock on port 2222)

This does not use `boog.age`. The allowed keys are `site.initrdAuthorizedKeys` in
`sites/home.nix`, which reads `nixosAdmin` from `secrets/keys.nix` at evaluation
time. If you rotate the NixOS Admin key, change `nixosAdmin` in `keys.nix`
(the site file and the initrd pick it up) and update `boog.plain`.

## GitHub deploy keys (per host)

1. Generate one per host:

   ```bash
   ssh-keygen -t ed25519 -f ./sheol-github -N "" -C "sheol-github-deploy"
   ```

2. Add `sheol-github.pub` on GitHub under the repo's **Settings, Deploy keys**.
3. Encrypt it and clean up:

   ```bash
   cp sheol-github secrets/ssh/github/sheol.plain
   ./secrets/ssh/github/encrypt.sh sheol
   rm -f sheol-github sheol-github.pub secrets/ssh/github/sheol.plain
   ```

4. Repeat for abaddon (the script accepts only `sheol` or `abaddon`; a new host
   means editing the check at the top of `github/encrypt.sh`). Commit the `.age`
   files and rebuild each host.
5. Test on the server: `ssh -T git@github.com` (it uses `~/.ssh/github`, per
   `users/boog/ssh.config`).

## Check a host key against `secrets.nix`

A host decrypts with its own SSH host key, so the key in `secrets/keys.nix` must
match the machine:

```bash
ssh sheol 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
ssh abaddon 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
```

If one differs, the host was reinstalled or rotated. Update `keys.nix`, run
`agenix -r` from `secrets/`, commit and rebuild.

## Interactive alternative

`agenix` is in the repo's dev shell (`direnv allow`, or `nix develop .#nix-config`),
and `RULES` already points at `secrets/secrets.nix`:

```bash
cd secrets
agenix -e ssh/authorized_keys/boog.age
```

Paste what you would have put in `boog.plain` when the editor opens. Outside the
dev shell, run it with
`nix run github:ryantm/agenix#agenix -- -e <file>` and set `RULES=$PWD/secrets.nix`.

`agenix` reads the private key from a file (`-i <file>`, default `~/.ssh/id_*`), not
from the SSH agent. To use the NixOS Admin key from 1Password without saving it,
in bash or zsh use `-i <(op read "op://<vault>/NixOS Admin/private key?ssh-format=openssh")`;
in fish use `-i (op read "..." | psub)`.
