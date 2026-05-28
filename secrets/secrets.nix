#
# Resources:
# https://nixos.wiki/wiki/Agenix
#

let
  sheol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5jDeelt6JuZ4EKKIWonGay4YSkF2+zIdfghwDo7phl";
  abaddon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILE9al/X5pmA8Fm+l/8B6kRQo+56dZtLt6ow/2D2EgOw";
  hosts = [
    sheol
    abaddon
  ];
  # 1Password "NixOS Admin" — same public key as authorized_keys/boog.plain.
  nixosAdmin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFxmhHVhJNRe+YzoVteozKpav1bsIVeY+Pr+Avlg2BN";

  # Who can encrypt/decrypt agenix files (NOT server GitHub deploy keys).
  agenixRecipients =
    (if nixosAdmin != null then [ nixosAdmin ] else [ ])
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECylZ+bt6dh7k1PW32yqV94A7T51copoWC0ePYOti6z"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFKW+qNCXZeRVyqyw92QdHXSXVZJ05X5BpzbcCvX04a"
      # Git signing only (users/darwin/git.nix)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
    ];
  users = agenixRecipients;
in
{
  "passwords/users/boog.age".publicKeys = hosts ++ users;
  "passwords/users/root.age".publicKeys = hosts ++ users;
  "passwords/k3s/token.age".publicKeys = hosts ++ users;
  "ssh/authorized_keys/boog.age".publicKeys = hosts ++ users;

  # GitHub deploy private keys — each host decrypts only its own.
  "ssh/github/sheol.age".publicKeys = [ sheol ] ++ users;
  "ssh/github/abaddon.age".publicKeys = [ abaddon ] ++ users;
}
