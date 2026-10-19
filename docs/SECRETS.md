# Secrets

Secrets are [agenix](https://github.com/ryantm/agenix) files under `secrets/`.
Each is encrypted to the SSH host keys of the machines that read it (plus the
admin key that edits it), so the repo can be public.

## Where each secret is declared

A secret is declared next to the module that uses it, so a host only decrypts
what its users and role need.

| Secret | Declared in | Used by |
| --- | --- | --- |
| `passwords/users/boog` | `users/boog/default.nix` | the `boog` account |
| `ssh/authorized_keys/boog` | `users/boog/authorized-keys.nix` | login keys for `boog` |
| `passwords/users/root` | `users/root/default.nix` | the `root` account |
| `passwords/k3s/token` | `hosts/abaddon/kubernetes.nix` | agent joining the k3s server |
| `ssh/github/<host>` | `modules/openssh.nix` (optional) | per-host GitHub deploy key |

Only agents need the k3s token; the server (sheol) does not read it.

## Adding a user

1. Create `users/<name>/default.nix` with its `age.secrets."passwords/users/<name>"`
   declaration and `hashedPasswordFile`.
2. Add the encrypted file to `secrets/secrets.nix` with the hosts that should be
   able to decrypt it, then create it with `cd secrets && agenix -e passwords/users/<name>.age`.
3. List the name in the host's `users = [ ... ]` in `flake.nix`.

## Adding a host

1. Install the host (see `docs/INSTALL.md`) and copy its SSH host public key into
   `secrets/keys.nix`.
2. Add the host to the recipient lists in `secrets/secrets.nix` for every secret
   it should read.
3. Re-encrypt: `cd secrets && agenix -r`.

## Re-keying (changing who can decrypt)

After editing recipients in `secrets/secrets.nix`, run `agenix -r` from `secrets/`
on a machine that holds a key which can already decrypt the files. Commit the
changed `.age` files.

## Initrd unlock keys (not in agenix)

Remote LUKS unlock needs material that exists before agenix can run:

- **Host keys** for the initrd ssh server live on each server under
  `/etc/secrets/initrd/` (`ssh_host_rsa_key`, `ssh_host_ed25519_key`). They are
  generated at install time (`docs/INSTALL.md`) and never enter the Nix store.
- **Who may unlock** is `site.initrdAuthorizedKeys` in the site file
  (`sites/home.nix`). Each key is restricted to `systemctl default`.

Changing the authorized keys changes the initrd, so reboot-test one server before
the other.
