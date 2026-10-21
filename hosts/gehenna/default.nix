# WSL host. Everything shared by WSL distros is in modules/wsl; this file only
# names the machine and its login user.
#
# TODO(gehenna): not installed yet, so it has only ever been evaluated, never built or
# switched. Before the first deploy:
#   1. Install it (docs/INSTALL.md, "Gehenna (WSL)") and read its SSH host public key
#      from /etc/ssh/ssh_host_ed25519_key.pub.
#   2. Add that key to secrets/keys.nix and to `hosts` in secrets/secrets.nix, then
#      re-key with `agenix -r` (docs/SECRETS.md, "Adding a host"). Until then it can
#      decrypt nothing, and the boog authorized-keys activation script
#      (users/boog/authorized-keys.nix) fails on switch because its secret is missing.
#   3. Build it once on x86_64-linux (`nixos-rebuild dry-activate --flake .#gehenna`
#      inside WSL); CI only evaluates it.
#   4. Decide whether it should read the shared secrets at all. The WSL role nulls the
#      password files and sets `users.allowNoPasswordLogin`, so only the authorized keys
#      and any deploy key need decrypting.
# `nixos_remote` does not know this host; deploy from inside the distro.
_: {
  networking.hostName = "gehenna";
  wsl.defaultUser = "boog";
}
