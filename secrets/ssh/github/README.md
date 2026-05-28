# GitHub deploy keys (sheol / abaddon)

Each server has its **own** ed25519 deploy key. Private keys live in agenix; NixOS installs them as `/home/boog/.ssh/github` (via `suites.nix` → `serverModules` → `modules/openssh.nix`).

## 1. Generate a deploy key (repeat per host)

```bash
cd secrets/ssh/github
ssh-keygen -t ed25519 -f ./sheol-github -N "" -C "sheol-github-deploy"
```

## 2. Register the public key on GitHub

Copy `sheol-github.pub` into each repo (or org) that host must clone:

**GitHub → Repository → Settings → Deploy keys → Add deploy key**

Use read-only unless the host must push.

## 3. Encrypt for agenix

```bash
cp sheol-github sheol.plain   # or paste PEM into sheol.plain
./encrypt.sh sheol
rm -f sheol.plain sheol-github sheol-github.pub   # do not commit private keys
git add sheol.age
```

Repeat with `abaddon-github` / `encrypt.sh abaddon`.

## 4. Rebuild that host

```bash
nixos-rebuild switch --flake .#sheol
```

Test from the server:

```bash
ssh -T git@github.com
git ls-remote git@github.com:YOUR_ORG/YOUR_REPO.git
```

`home/ssh/default.config` uses `~/.ssh/github` for `Host github.com`.
