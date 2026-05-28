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
  agenixRecipients =
    [
      keys.nixosAdmin
      keys.gitSigning
    ]
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECylZ+bt6dh7k1PW32yqV94A7T51copoWC0ePYOti6z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFKW+qNCXZeRVyqyw92QdHXSXVZJ05X5BpzbcCvX04a"
    ];
  users = agenixRecipients;
in
{
  "passwords/users/boog.age".publicKeys = hosts ++ users;
  "passwords/users/root.age".publicKeys = hosts ++ users;
  "passwords/k3s/token.age".publicKeys = hosts ++ users;
  "ssh/authorized_keys/boog.age".publicKeys = hosts ++ users;

  "ssh/github/sheol.age".publicKeys = [ keys.sheol ] ++ users;
  "ssh/github/abaddon.age".publicKeys = [ keys.abaddon ] ++ users;
}
