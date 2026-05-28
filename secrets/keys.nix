# SSH public keys — imported by secrets.nix, boot.nix, and users/darwin/git.nix.
# agenix cannot read this file; it only sees the attrset returned by secrets.nix.
{
  sheol = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5jDeelt6JuZ4EKKIWonGay4YSkF2+zIdfghwDo7phl";
  abaddon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILE9al/X5pmA8Fm+l/8B6kRQo+56dZtLt6ow/2D2EgOw";

  nixosAdmin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFxmhHVhJNRe+YzoVteozKpav1bsIVeY+Pr+Avlg2BN";
  gitSigning = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex";
}
