#
# Resources:
# https://nixos.wiki/wiki/Agenix
#

let
  sheol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5jDeelt6JuZ4EKKIWonGay4YSkF2+zIdfghwDo7phl";
  abaddon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILE9al/X5pmA8Fm+l/8B6kRQo+56dZtLt6ow/2D2EgOw";
  mephistopheles-WSL = "";
  hosts = [
    sheol
    abaddon
    mephistopheles-WSL
  ];
  boog = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECylZ+bt6dh7k1PW32yqV94A7T51copoWC0ePYOti6z"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFKW+qNCXZeRVyqyw92QdHXSXVZJ05X5BpzbcCvX04a"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
  ];
  users = boog;
in
{
  "passwords/users/boog.age".publicKeys = hosts ++ users;
  "passwords/users/root.age".publicKeys = hosts ++ users;
  "passwords/k3s/token.age".publicKeys = hosts ++ users;
}
