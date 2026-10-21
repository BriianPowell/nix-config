# SSH secrets (agenix)

Runbook for the SSH-related secrets. Concepts (who can decrypt, adding users and
hosts, re-keying) are in [`docs/SECRETS.md`](../../docs/SECRETS.md).

Everything here uses `agenix`, which is in the repo's dev shell (`direnv allow`, or
`nix develop .#nix-config`). `RULES` already points at `secrets/secrets.nix`, and file
names are relative to `secrets/`, so the commands work from anywhere in the repo.

`agenix -e <file>.age` encrypts to the recipients of that file's rule in
`secrets.nix`. With piped input it replaces the contents without opening an editor and
without needing a private key, which is how the commands below work. Without piped
input it opens `$EDITOR` and needs your admin key (`-i <key>`).

| Secret | Ends up on the host |
| --- | --- |
| `ssh/authorized_keys/boog.age` | `/home/boog/.ssh/authorized_keys`, written by an activation script |
| `ssh/github/sheol.age` | `/home/boog/.ssh/github` on sheol |
| `ssh/github/abaddon.age` | `/home/boog/.ssh/github` on abaddon |

Commit only `*.age` files. `*.plain` is in `.gitignore` as a safety net, but the
commands below need no plaintext file in the repo.

## Using this if you fork the repo

The `.age` files, the keys in `secrets/keys.nix` and the recipient lists in
`secrets/secrets.nix` belong to the original owner; none of them decrypt for you.
Replace them in this order (`docs/SECRETS.md` has the concepts):

1. **Make an admin key** you keep private (any ed25519 key; a hardware or password
   manager key works). Put its **public** half in `secrets/keys.nix` as `nixosAdmin`,
   and delete the other entries you don't use (`gitSigning`, hosts that aren't yours).
2. **Add your hosts' keys.** Install a host first, then copy its public key from
   `/etc/ssh/ssh_host_ed25519_key.pub` into `keys.nix` and into `hosts` in
   `secrets/secrets.nix`. A host can only decrypt after its key is listed.
3. **Delete every `*.age` file**, then create your own, one command each, from the
   repo's dev shell. Names must match the rules in `secrets/secrets.nix` (rename or add
   rules for your own users and hosts):

   ```bash
   # login password hash for a user, and for root
   nix run nixpkgs#mkpasswd -- -m yescrypt | agenix -e passwords/users/<user>.age
   nix run nixpkgs#mkpasswd -- -m yescrypt | agenix -e passwords/users/root.age

   # public keys allowed to log in as that user (see "Update login keys" below)
   agenix -e ssh/authorized_keys/<user>.age < ~/my-keys.txt

   # only if a host sets k3sNode.tokenSecret: a plain random token, no trailing newline
   openssl rand -hex 32 | tr -d '\n' | agenix -e passwords/k3s/token.age
   ```

   Without a private key, `agenix -e` with piped input still works, because it only
   needs the public keys in `secrets.nix`. To read a file back you need the admin key
   (`agenix -d <file> -i <key>`).
4. **Point the modules at your files.** The paths are in `users/<name>/`,
   `hosts/<name>/` and `sites/*.nix`; `secrets/keys.nix` is also read by `sites/*.nix`
   for the initrd unlock key.
5. Run `nix flake check`. Its fork check builds a made-up server from only a site and a
   user, so a leftover value of the original owner is reported.

The rest of this file assumes the original names (`boog`, `sheol`, `abaddon`); read
them as your own user and hosts.

## Update login keys

Put the public keys that may log in as `boog`, one per line, in a file outside the
repo (comments and blank lines are fine), then:

```bash
keys="$(grep -v '^[[:space:]]*#' ~/boog-keys.txt | grep -v '^[[:space:]]*$')" \
  && [ -n "$keys" ] && printf '%s\n' "$keys" | agenix -e ssh/authorized_keys/boog.age
```

The `[ -n "$keys" ]` guard matters: `agenix -e` with empty piped input happily encrypts
an empty list, and the next deploy would leave the account with no login keys. A
missing or comment-only file fails the command instead. (In fish, use
`set keys (grep ... | grep ...)` and `test -n "$keys"` in place of the `$(...)` form.)

**Check before you commit and deploy:** the list must still contain your admin key.

```bash
agenix -d ssh/authorized_keys/boog.age -i <key> | wc -l            # not 0
agenix -d ssh/authorized_keys/boog.age -i <key> | ssh-keygen -lf - # your key is listed
```

Then commit `boog.age` and `nixos-rebuild switch` on the servers.

The Mac's login key is the **NixOS Admin** item in 1Password (see
`users/darwin/ssh.config` and `users/darwin/1password-agent.toml`). Do not set
`IdentitiesOnly yes` without an `IdentityFile`, because that skips the 1Password
agent. Git signing uses `keys.gitSigning` (`users/darwin/git.nix`); keep the
Personal key, not NixOS Admin, in `agent.toml`.

## Initrd (LUKS unlock on port 2222)

This does not use `boog.age`. The allowed keys are `site.initrdAuthorizedKeys` in
`sites/home.nix`, which reads `nixosAdmin` from `secrets/keys.nix` at evaluation
time. If you rotate the NixOS Admin key, change `nixosAdmin` in `keys.nix` (the site
file and the initrd pick it up) and update the login keys above.

## GitHub deploy keys (per host)

1. Generate one per host:

   ```bash
   ssh-keygen -t ed25519 -f ./sheol-github -N "" -C "sheol-github-deploy"
   ```

2. Add `sheol-github.pub` on GitHub under the repo's **Settings, Deploy keys**.
3. Encrypt the private key and clean up:

   ```bash
   agenix -e ssh/github/sheol.age < ./sheol-github
   rm -f ./sheol-github ./sheol-github.pub
   ```

4. Repeat for abaddon. A new host also needs a rule for `ssh/github/<host>.age` in
   `secrets.nix`. Commit the `.age` files and rebuild each host.
5. Test on the server: `ssh -T git@github.com` (it uses `~/.ssh/github`, per
   `users/boog/ssh.config`).

## Check a host key against `keys.nix`

A host decrypts with its own SSH host key, so the key in `secrets/keys.nix` must
match the machine:

```bash
ssh sheol 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
ssh abaddon 'awk "{print \$1, \$2}" /etc/ssh/ssh_host_ed25519_key.pub'
```

If one differs, the host was reinstalled or rotated. Update `keys.nix`, run
`agenix -r` (docs/SECRETS.md, "Re-keying"), commit and rebuild.

## Reading or editing a secret

```bash
agenix -d ssh/authorized_keys/boog.age -i <key>   # print it
agenix -e ssh/authorized_keys/boog.age -i <key>   # edit in $EDITOR
```

`agenix` reads the private key from a file, not from the SSH agent. To use the NixOS
Admin key from 1Password without saving it, in bash or zsh pass
`-i <(op read "op://<vault>/NixOS Admin/private key?ssh-format=openssh")`; in fish
pass `-i (op read "..." | psub)`.
