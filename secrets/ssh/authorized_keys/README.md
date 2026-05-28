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
