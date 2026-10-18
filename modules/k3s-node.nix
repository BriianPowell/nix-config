#
# Settings every k3s node (server or agent) shares. Host files set
# `k3sNode.ip`, the role, and anything role-specific.
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.k3sNode;
in
{
  options.k3sNode = {
    ip = lib.mkOption {
      type = lib.types.str;
      description = "Node IP, used as both the internal and external address.";
    };
    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "k3s flags beyond the node name/IP/data-dir this module sets.";
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.k3s
      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../scripts/k3s-reset-node))
      (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (
        builtins.readFile ../scripts/k3s-remove-unused-rs
      ))
    ];

    services.k3s = {
      enable = true;
      extraFlags = toString (
        [
          "--node-name ${config.networking.hostName}"
          "--node-ip ${cfg.ip}"
          "--node-external-ip ${cfg.ip}"
          "--data-dir /var/lib/rancher/k3s"
        ]
        ++ cfg.extraFlags
      );
    };

    networking.firewall = {
      allowedTCPPorts = [
        2379 # HA with embedded etcd
        2380 # HA with embedded etcd
        6443 # k8s API server
        10250 # Kubelet Metrics
      ];
      allowedUDPPorts = [
        8472 # flannel: inter-node networking
      ];
      # Trust the node's own NICs plus the CNI bridge and loopback.
      trustedInterfaces = (builtins.attrNames config.networking.interfaces) ++ [
        "cni0"
        "lo"
      ];
    };
  };
}
