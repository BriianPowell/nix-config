{ config, ... }: {
  # Package, helper scripts, firewall base and node flags: modules/server/k3s-node.nix.
  services.k3s = {
    role = "agent";
    serverAddr = "https://${config.site.hosts.sheol.ip}:6443";
    tokenFile = config.age.secrets."passwords/k3s/token".path;
  };
}
