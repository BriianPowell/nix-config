# SSH secrets (agenix)

| Secret | Plaintext input | On host |
|--------|-----------------|---------|
| `authorized_keys/boog.age` | `authorized_keys/boog.plain` (public keys, one per line) | `/home/boog/.ssh/authorized_keys` via activation |
| `github/sheol.age` | `github/sheol.plain` (private deploy key) | `/home/boog/.ssh/github` |
| `github/abaddon.age` | `github/abaddon.plain` (private deploy key) | `/home/boog/.ssh/github` |

Plaintext `*.plain` files are gitignored. Commit only `*.age` files.

Encryption uses the same format as **agenix 0.15**: `age -r "ssh-ed25519 AAAA…"` (not `ssh-to-age`). Use the provided `encrypt.sh` scripts.

## Mac login (sheol / abaddon)

- **1Password** item **NixOS Admin** (Tech Stack) — see `home/ssh/darwin.config` and `home/config/1Password/ssh/agent.toml`.
- Do not use `IdentitiesOnly yes` without `IdentityFile` (that skips the 1Password agent).
- **Git signing** uses `keys.gitSigning` in `secrets/keys.nix` (imported by `users/darwin/git.nix`). Keep **Personal** in `agent.toml`, not NixOS Admin.

### Update login keys

1. Put the NixOS Admin **public** key in `authorized_keys/boog.plain`.
2. From repo root:

   ```bash
   ./secrets/ssh/authorized_keys/encrypt.sh
   ```

3. If the key changed, update `secrets/keys.nix` (`nixosAdmin`).
4. Commit `boog.age` (and `secrets/keys.nix` if changed).
5. `nixos-rebuild switch` on sheol and abaddon.

### Initrd / LUKS (port 2222)

Initrd uses `secrets/keys.nix` directly (`nixosAdmin`) at eval time—not `boog.age`.

## GitHub deploy keys (per host)

1. Generate (once per host):

   ```bash
   ssh-keygen -t ed25519 -f ./sheol-github -N "" -C "sheol-github-deploy"
   ```

2. Add `sheol-github.pub` on GitHub → repo → **Settings → Deploy keys**.

3. Encrypt:

   ```bash
   cp sheol-github secrets/ssh/github/sheol.plain
   ./secrets/ssh/github/encrypt.sh sheol
   rm -f sheol-github sheol-github.pub secrets/ssh/github/sheol.plain
   ```

4. Repeat for abaddon. Commit `sheol.age` / `abaddon.age`, rebuild each host.

5. Test on the server: `ssh -T git@github.com` (uses `~/.ssh/github` per `home/ssh/default.config`).

## Host keys in `secrets.nix`

Each host must decrypt its own secrets. Compare live keys to `secrets/secrets.nix`:

```bash
ssh sheol 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
ssh abaddon 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
```

If a host key rotated, update `secrets.nix`, re-run the `encrypt.sh` scripts, commit, and rebuild.

## Alternative: `agenix -e` (interactive)

From `secrets/` in iTerm:

```bash
export RULES=$PWD/secrets.nix
nix run github:ryantm/agenix#agenix -- -e ssh/authorized_keys/boog.age
```

Paste the same content as `boog.plain` when the editor opens.
