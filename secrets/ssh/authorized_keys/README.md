# Login keys for user `boog`

## Running system (sheol / abaddon)

Public keys live in **`boog.age`** only. At activation, agenix decrypts to `/run/agenix/…` and `users/boog/authorized-keys.nix` copies them to `/home/boog/.ssh/authorized_keys`.

No `boog.pub` in git.

## Update keys

1. Edit `boog.plain` (one public key per line).
2. `./encrypt.sh` → updates `boog.age`.
3. If the key changed, mirror the same line(s) in `../initrd-login.nix` (initrd cannot use agenix at build time).
4. Commit `boog.age` (+ `initrd-login.nix` if it changed).
5. `nixos-rebuild switch` on each host.

## Initrd (port 2222)

`secrets/ssh/initrd-login.nix` is the only build-time copy of the login pubkey(s). That is a NixOS limitation for LUKS SSH in initrd—not a second agenix mount.

## Mac

1Password **NixOS Admin** must match the key inside `boog.age` / `initrd-login.nix`.

## `no identity matched any of the recipients` on rebuild

Password `.age` files decrypt but new `ssh/*.age` files fail → those files were encrypted for the wrong public keys (often before `secrets.nix` had the correct host key).

On **sheol**:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Must match the `sheol = "ssh-ed25519 …"` line in `secrets/secrets.nix`. If not, fix `secrets.nix`, then on your **Mac** (from repo root):

```bash
./secrets/ssh/rekey-ssh-secrets.sh
```

Commit the updated `.age` files, pull on sheol, `sudo nixos-rebuild switch` again.
