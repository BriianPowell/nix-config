#
# Settings every k3s node (server or agent) shares. Host files set
# the role and anything role-specific. The node IP comes from the site file.
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
      default =
        (config.site.hosts.${config.networking.hostName}
          or (throw "k3sNode.ip: no site.hosts.${config.networking.hostName} entry; add one to your site file or set k3sNode.ip")
        ).ip;
      defaultText = lib.literalExpression "config.site.hosts.\${config.networking.hostName}.ip";
      description = "Node IP, used as both the internal and external address. Defaults to the host's entry in the site file.";
    };
    tokenSecret = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        agenix file holding the cluster join token (the plain secret, without the
        `K10...::server:` prefix). Every node reads it, so the token survives a wipe
        of the server's data directory. Null lets a server generate its own token.
      '';
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
      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
      (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (
        builtins.readFile ../../scripts/k3s-remove-unused-rs
      ))
    ];

    age.secrets."passwords/k3s/token" = lib.mkIf (cfg.tokenSecret != null) {
      file = cfg.tokenSecret;
    };

    services.k3s = {
      enable = true;
      tokenFile = lib.mkIf (cfg.tokenSecret != null) config.age.secrets."passwords/k3s/token".path;
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
      # node-exporter runs with hostNetwork/hostPort 9100 on every node, and the trusted NICs above
      # would let the whole LAN read its host metrics. Only Prometheus (a pod, 10.42.0.0/16, or a pod
      # on the other node, which leaves through that node's IP) and the nodes themselves may scrape it.
      # extraCommands run after the trusted-interface accept, so the rules go at the top of the
      # chain; each -I 1 lands in front of the previous one (final order: accepts, then drop).
      extraCommands = ''
        iptables -w -I nixos-fw 1 -p tcp --dport 9100 -j DROP
        iptables -w -I nixos-fw 1 -p tcp --dport 9100 -s 127.0.0.0/8 -j ACCEPT
        iptables -w -I nixos-fw 1 -p tcp --dport 9100 -s 10.42.0.0/16 -j ACCEPT
        iptables -w -I nixos-fw 1 -p tcp --dport 9100 -s ${config.site.hosts.sheol.ip} -j ACCEPT
        iptables -w -I nixos-fw 1 -p tcp --dport 9100 -s ${config.site.hosts.abaddon.ip} -j ACCEPT
      '';
    };
  };
}
