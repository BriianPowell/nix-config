{ config, ... }: {
  # Package, helper scripts, firewall base and node flags: modules/server/k3s-node.nix.

  # Only agents join with the server's token; the server (sheol) never reads it.
  age.secrets."passwords/k3s/token".file = ../../secrets/passwords/k3s/token.age;

  services.k3s = {
    role = "agent";
    serverAddr = "https://${config.site.hosts.sheol.ip}:6443";
    tokenFile = config.age.secrets."passwords/k3s/token".path;
  };
}
