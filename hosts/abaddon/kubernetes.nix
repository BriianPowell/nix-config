{ config, ... }:
{
  # Package, helper scripts, firewall base, node flags and the join token: modules/server/k3s-node.nix.
  k3sNode.tokenSecret = ../../secrets/passwords/k3s/token.age;

  services.k3s = {
    role = "agent";
    serverAddr = "https://${config.site.hosts.sheol.ip}:6443";
  };
}
