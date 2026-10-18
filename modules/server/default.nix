# Everything a k3s server node needs. Hosts add their own values on top.
{
  imports = [
    ../i18n.nix
    ../minimal-docs.nix
    ../openssh.nix
    ../security.nix
    ../site.nix
    ./base.nix
    ./boot.nix
    ./hardware.nix
    ./k3s-node.nix
    ./tcp-hardening.nix
    ./tcp-optimization.nix
  ];
}
