# Secrets

Secrets are [agenix](https://github.com/ryantm/agenix) files under `secrets/`.
Each is encrypted to the SSH host keys of the machines that read it (plus the
admin key that edits it), so the repo can be public. Recipients are listed in
`secrets/secrets.nix`; public keys are in `secrets/keys.nix`.

This file covers *where* each secret is declared, who can decrypt it, and how that
changes when you add users or hosts. The commands for the SSH material (login
keys, GitHub deploy keys, checking a host key) are in
[`secrets/ssh/README.md`](../secrets/ssh/README.md).

## Where each secret is declared

A secret is declared next to the module that uses it, so a host only decrypts
what its users and role need.

| Secret | Declared in | Used by |
| --- | --- | --- |
| `passwords/users/boog` | `users/boog/default.nix` | the `boog` account |
| `ssh/authorized_keys/boog` | `users/boog/authorized-keys.nix` | login keys for `boog` |
| `passwords/users/root` | `users/root/default.nix` | the `root` account |
| `passwords/k3s/token` | `modules/server/k3s-node.nix`, when a host sets `k3sNode.tokenSecret` | the k3s join token, read by sheol and abaddon |
| `ssh/github/<host>` | `users/boog/github-deploy-key.nix` (optional) | per-host GitHub deploy key |

The k3s token is the plain secret only, without the `K10...::server:` prefix that
`/var/lib/rancher/k3s/server/token` shows. Both nodes read it, so the cluster
rejoins after the server's data directory is wiped. A plain token means agents do
not pin the server's CA at first join, which suits a fixed address on a wired
network. To change it: `agenix -e passwords/k3s/token.age`, then redeploy abaddon
and then sheol (the server's etcd data is encrypted with this token, so a changed
value needs the cluster reset steps in k3s's docs).

## Who can decrypt (`secrets/secrets.nix`)

`secrets/keys.nix` holds the public keys; `secrets/secrets.nix` is the agenix rules
file that maps each `.age` file to the keys that may decrypt it. It has two lists
and one rule per file:

- `hosts`: the machines' SSH host keys (`keys.sheol`, `keys.abaddon`).
- `users` (inside the file, despite the name): the **admin recipients**, the keys
  that can edit secrets from a workstation. These are not user accounts. Today it is
  only `keys.nixosAdmin` (the same key you log in to servers with). The git signing
  key is deliberately not a recipient, so signing and decrypting stay separate.
- Most rules read `hosts ++ users`. The per-host GitHub deploy keys
  (`ssh/github/<host>.age`) are encrypted to that one host plus the admins.

A host that is not in `hosts` cannot decrypt any shared secret. For a server that
fails at activation, so every server must be a recipient before its first switch.

## Adding a user

1. Create `users/<name>/default.nix` with its `age.secrets."passwords/users/<name>"`
   declaration and `hashedPasswordFile`.
2. Add a rule to `secrets/secrets.nix`:
   `"passwords/users/<name>.age".publicKeys = hosts ++ users;`, then create the file
   with `cd secrets && agenix -e passwords/users/<name>.age`. For SSH material use
   the `encrypt.sh` flow in `secrets/ssh/README.md`.
3. List the name in the host's `users = [ ... ]` in `flake.nix`.

## Adding a host

1. Install the host (see `docs/INSTALL.md`) and copy its SSH host public key into
   `secrets/keys.nix`.
2. Add it to the `hosts` list in `secrets/secrets.nix`. That gives it every shared
   secret. If it has a GitHub deploy key, add an `ssh/github/<host>.age` rule too.
3. Re-encrypt so the existing files include the new key:
   `cd secrets && agenix -r`.

WSL hosts follow the same rule. `gehenna` is not in `hosts` yet, so it can decrypt
nothing; the WSL role sets the password files to `null` to cope with that, but the
`boog` authorized-keys activation script still expects its secret. Add gehenna's
key to `hosts` (steps above) before deploying it.

## Re-keying (changing who can decrypt)

After editing `hosts` or the admin recipients in `secrets/secrets.nix`, run
`agenix -r` from `secrets/` on a machine that holds a key which can already decrypt
the files. Commit the changed `.age` files. If a host's SSH key rotates, update
`secrets/keys.nix` first (`secrets/ssh/README.md` has the commands to compare live
keys).

A fork replaces `secrets/keys.nix` and the key lists in `secrets/secrets.nix` with
its own, deletes the `.age` files and creates new ones. Nothing here can be
decrypted without the original private keys.

## Initrd unlock keys (not in agenix)

Remote LUKS unlock needs material that exists before agenix can run:

- **Host keys** for the initrd ssh server live on each server under
  `/etc/secrets/initrd/` (`ssh_host_rsa_key`, `ssh_host_ed25519_key`). They are
  generated at install time (`docs/INSTALL.md`) and never enter the Nix store.
- **Who may unlock** is `site.initrdAuthorizedKeys` in the site file
  (`sites/home.nix`). Each key is restricted to `systemctl default`.

Changing the authorized keys changes the initrd, so reboot-test one server before
the other.
