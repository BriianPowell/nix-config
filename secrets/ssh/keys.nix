# SSH public keys (single source of truth). Plaintext is fine — public keys only.
{
  # 1Password "NixOS Admin" — Mac login to sheol/abaddon; see authorized_keys/boog.age.
  nixosAdmin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFxmhHVhJNRe+YzoVteozKpav1bsIVeY+Pr+Avlg2BN";

  # 1Password "Personal" (or dedicated item) — git commit signing on Mac only.
  gitSigning = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex";
}
