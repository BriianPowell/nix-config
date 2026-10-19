# A made-up site for the fork acceptance check (see `checks.fork-example` in
# flake.nix). It stands in for a fork's own sites/<name>.nix.
_: {
  site = {
    servers = {
      gateway = "192.168.1.1";
      dns = [ "192.168.1.1" ];
    };

    hosts.example-node.ip = "192.168.1.50";

    initrdAuthorizedKeys = [ "ssh-ed25519 AAAAexample-not-a-real-key example" ];
  };
}
