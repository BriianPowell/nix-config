# SSH login keys for user `boog` (agenix)

Servers read `ssh/authorized_keys/boog.age` via `users/boog/default.nix` (`openssh.authorizedKeys.keyFiles`).

## Which key goes in the secret?

| Key | Where it lives | Used for |
|-----|----------------|----------|
| **1Password "NixOS Admin"** | Tech Stack vault | SSH from Mac → sheol/abaddon |
| **`~/.ssh/github_deploy` on server** | agenix per host | `git@github.com` from sheol/abaddon only |
| **Git signing key** | `users/darwin/git.nix` | Signed commits on Mac, not server login |

Mac SSH (`home/ssh/darwin.config`) uses the 1Password agent with `IdentitiesOnly yes` for NixOS hosts. The agenix secret must contain the **NixOS Admin** public key.

You do **not** need `~/.ssh/id_ed25519` on your Mac to create or deploy this secret.

## Create `boog.age` (no private key on Mac)

1. Copy the **NixOS Admin** public key from 1Password into `boog.plain` (see `secrets/ssh/README.md`).
2. From the repo:

   ```bash
   ./secrets/ssh/authorized_keys/encrypt.sh
   ```

   This encrypts using every public key listed in `secrets/secrets.nix` (hosts + `agenixRecipients`). No local `~/.ssh` private key is required.

3. Commit `boog.age`, rebuild sheol/abaddon:

   ```bash
   nixos-rebuild switch --flake .#sheol
   ```

4. **Initrd / LUKS unlock (port 2222):** the key file is written to `/etc/ssh/authorized_keys/boog`. After the first successful switch, run **one more** rebuild so initrd picks up that file.

## Optional: add Personal pubkey to `secrets.nix`

If you want to edit this secret later with `agenix -e` using a key you control, add your Personal **public** key to `agenixRecipients` in `secrets/secrets.nix` and run `agenix -r`. That still does not require storing the private key in `~/.ssh` (1Password keeps it).
