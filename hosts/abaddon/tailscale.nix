# Joins the tailnet as a tagged node. Setup and the tailnet side: docs/TAILSCALE.md.
_: {
  tailscale = {
    enable = true;
    authKeyFile = ../../secrets/tailscale/auth-key.age;
    tags = [ "tag:server" ];
    # abaddon is an agent: no Kubernetes API here, so only SSH (the default) is open.
  };
}
