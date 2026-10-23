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
  # One accept per host in the site file, so no host name is written here (a fork's
  # site has different hosts).
  nodeAccepts = lib.concatMapStrings (host: ''
    iptables -w -I nixos-fw 1 -s ${host.ip} -j ACCEPT
  '') (lib.reverseList (lib.attrValues config.site.hosts));
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
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames config.networking.interfaces;
      defaultText = lib.literalExpression "builtins.attrNames config.networking.interfaces";
      description = "The node's LAN NICs. They are untrusted; only the ports listed here and in the firewall module are open on them.";
    };
    lanTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "Extra TCP ports to open on the LAN NICs only.";
    };
    lanUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "Extra UDP ports to open on the LAN NICs only.";
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

    # The LAN NICs are NOT trusted: only the CNI bridge, flannel and loopback are. Pods reach the node's
    # own services through cni0, so Prometheus scraping, Traefik and HA keep working. Everything else
    # follows default-drop plus the lists below:
    #   - every interface: 22, 2022, 80, 443 (modules/server/base.nix)
    #   - the LAN NICs: the k8s API (kubectl from the Mac and the WireGuard clients), DHCP, and whatever
    #     the host file adds in k3sNode.lanTCPPorts/lanUDPPorts
    #   - the two nodes: everything from each other's IP (etcd, kubelet, flannel VXLAN, metrics). A pod on
    #     one node reaching a service on the other leaves through its node IP, so this covers that too.
    # hostPort/NodePort traffic (Traefik, Plex, MQTT, game servers) is DNATed and forwarded, so it never
    # touches this INPUT chain and is unaffected.
    networking.firewall = {
      trustedInterfaces = [
        "cni0"
        "flannel.1"
        "lo"
      ];
      interfaces = lib.genAttrs cfg.lanInterfaces (_: {
        allowedTCPPorts = [ 6443 ] ++ cfg.lanTCPPorts;
        allowedUDPPorts = [ 68 ] ++ cfg.lanUDPPorts;
      });
      # extraCommands run after the trusted-interface accept, so the rules go at the top of the chain.
      extraCommands = nodeAccepts;
    };
  };
}
