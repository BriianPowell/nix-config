# WSL manages its own networking, firewall and init; we only pull in the
# locale/docs/ssh/security modules that make sense inside a WSL distro.
{
  imports = [
    ../i18n.nix
    ../minimal-docs.nix
    ../openssh.nix
    ../security.nix
  ];
}
