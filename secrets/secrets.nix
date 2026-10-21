#
# agenix rules only: maps *.age paths → who can decrypt.
# Public keys live in keys.nix (imported here and by NixOS/Darwin modules).
#
# https://nixos.wiki/wiki/Agenix
#
let
  keys = import ./keys.nix;
  hosts = [
    keys.sheol
    keys.abaddon
  ];
  # Admin recipients: keys that can edit secrets from a workstation (not user accounts).
  users = [ keys.nixosAdmin ];
in
{
  "passwords/users/boog.age".publicKeys = hosts ++ users;
  "passwords/users/root.age".publicKeys = hosts ++ users;
  "passwords/k3s/token.age".publicKeys = hosts ++ users;
  "ssh/authorized_keys/boog.age".publicKeys = hosts ++ users;

  "ssh/github/sheol.age".publicKeys = [ keys.sheol ] ++ users;
  "ssh/github/abaddon.age".publicKeys = [ keys.abaddon ] ++ users;
}
