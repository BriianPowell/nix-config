# SSH secrets (agenix)

| Path | Purpose |
|------|---------|
| [authorized_keys/](authorized_keys/) | **Your** login public key(s) → server `authorized_keys` for user `boog` |
| [github/](github/) | **Per-host** GitHub deploy **private** keys → `~/.ssh/github_deploy` on sheol/abaddon |

## Admin login (Mac → sheol / abaddon)

1. Use the **NixOS Admin** SSH item in 1Password (Tech Stack). Mac SSH uses the 1Password agent (`home/ssh/darwin.config`, `home/config/1Password/ssh/agent.toml`).

2. Add that item’s **public** key to `authorized_keys/boog.plain`, run `./authorized_keys/encrypt.sh`, commit `boog.age`.

3. Optional: set the same pubkey as `nixosAdmin` in `secrets/secrets.nix` to edit agenix secrets from a machine with that key.

4. Rebuild sheol and abaddon.

## Git signing (Mac)

Keep using a **separate** key in `users/darwin/git.nix` — do not use `nixos_admin` for commit signing.
