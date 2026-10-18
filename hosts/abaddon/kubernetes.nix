{ config, ... }: {
  # Package, helper scripts, firewall base and node flags: modules/server/k3s-node.nix.
  k3sNode.ip = "10.0.2.11";

  services.k3s = {
    role = "agent";
    serverAddr = "https://10.0.2.10:6443";
    tokenFile = config.age.secrets."passwords/k3s/token".path;
  };
}
