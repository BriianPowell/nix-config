#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
# https://docs.k3s.io/advanced#configuring-containerd
# https://github.com/k3s-io/k3s/issues/6518
#

{
  config,
  pkgs,
  lib,
  ...
}:
let
  toolkitTools = pkgs.nvidia-container-toolkit.tools;
  # CDI mode in nvidia-container-runtime config.toml (see nvidia.nix).
  nvidiaContainerRuntime = "${toolkitTools}/bin/nvidia-container-runtime.cdi";

  # Cannot add [plugins."io.containerd.grpc.v1.cri"] here — base template already defines it
  # and TOML rejects duplicate tables (containerd exit 1). Use drop-in below.
  cdiDropin = pkgs.writeText "cdi.toml" ''
    [plugins."io.containerd.grpc.v1.cri"]
      enable_cdi = true
  '';

  containerdConfigTemplate = ''
    {{ template "base" . }}

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "${nvidiaContainerRuntime}"
  '';

  containerdTemplate = pkgs.writeText "config.toml.tmpl" containerdConfigTemplate;
in
{
  # Package, helper scripts, firewall base and node flags: modules/server/k3s-node.nix.
  environment.systemPackages = with pkgs; [
    docker
    runc
  ];

  # https://nixos.wiki/wiki/Nvidia#NVIDIA_Docker_not_Working
  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
  };

  # Same token as abaddon reads, so a wipe of this node's data cannot break the join.
  k3sNode.tokenSecret = ../../secrets/passwords/k3s/token.age;

  services.k3s = {
    role = "server";
    clusterInit = true;
  };

  k3sNode.extraFlags = [
    "--flannel-backend host-gw"
    "--disable traefik"
    "--disable metrics-server"
    "--etcd-expose-metrics"
    "--kube-proxy-arg --metrics-bind-address=0.0.0.0" # Required for prometheus monitoring of kube-proxy
    "--kube-controller-manager-arg --bind-address=0.0.0.0" # Required for prometheus monitoring of kube-controller-manager
    "--kube-scheduler-arg --bind-address=0.0.0.0" # Required for prometheus monitoring of kube-scheduler
    # CIS-oriented server hardening: https://docs.k3s.io/security/hardening-guide
    "--secrets-encryption"
    "--protect-kernel-defaults"
    "--kube-apiserver-arg=audit-log-path=/var/lib/rancher/k3s/server/logs/audit.log"
    "--kube-apiserver-arg=audit-policy-file=/var/lib/rancher/k3s/server/audit.yaml"
    "--kube-apiserver-arg=audit-log-maxage=30"
    "--kube-apiserver-arg=audit-log-maxbackup=10"
    "--kube-apiserver-arg=audit-log-maxsize=100"
    "--kube-apiserver-arg=service-account-extend-token-expiration=false"
    "--kubelet-arg=streaming-connection-idle-timeout=5m"
    # Unsafe sysctls pods may set on this node. This flag REPLACES k3s's own default allowlist, so
    # it must keep the sysctls k3s's service-LB pods (svclb-*) request, or they fail with
    # SysctlForbidden and Traefik/AdGuard stop answering on this node (this happened once).
    #   net.ipv4.ip_forward, net.ipv6.conf.all.forwarding: k3s servicelb (svclb-*) pods
    #   net.ipv4.conf.all.src_valid_mark: Deluge (k3s-collective apps/media/deluge); wg-quick needs
    #     it to run unprivileged with NET_ADMIN. Namespaced to the pod. Sheol only (Deluge is pinned here).
    "--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.ip_forward,net.ipv6.conf.all.forwarding,net.ipv4.conf.all.src_valid_mark"
    "--kubelet-arg=tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
  ];

  system.activationScripts.writeContainerdConfigTemplate = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/rancher/k3s/agent/etc/containerd
    cp ${containerdTemplate} /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
    mkdir -p /var/lib/rancher/k3s/agent/etc/containerd/config.toml.d
    cp ${cdiDropin} /var/lib/rancher/k3s/agent/etc/containerd/config.toml.d/99-cdi.toml
  '';

  system.activationScripts.k3sServerHardening = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/rancher/k3s/server/logs
    chmod 700 /var/lib/rancher/k3s/server/logs
    install -m 600 ${./k3s/audit.yaml} /var/lib/rancher/k3s/server/audit.yaml
    if [ -d /var/lib/rancher/k3s/server/tls ]; then
      chmod 700 /var/lib/rancher/k3s/server/tls
      find /var/lib/rancher/k3s/server/tls -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' \) -exec chmod 600 {} \;
    fi
  '';

  # k3s may recreate certs with looser modes; re-apply after the server is up.
  systemd.services.k3s-pki-permissions = {
    description = "Restrict k3s server TLS key/cert permissions (CIS)";
    wantedBy = [ "multi-user.target" ];
    after = [ "k3s.service" ];
    requires = [ "k3s.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      tls=/var/lib/rancher/k3s/server/tls
      [ -d "$tls" ] || exit 0
      chmod 700 "$tls"
      find "$tls" -type f \( -name '*.crt' -o -name '*.key' -o -name '*.pem' \) -exec chmod 600 {} \;
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [
      2381 # etcd metrics (--etcd-expose-metrics)
      21063 # Home Assistant on k3s
    ];
    allowedUDPPorts = [
      5353 # Home Assistant on k3s
    ];

    # Home Assistant runs with hostNetwork (HomeKit needs mDNS and 21063 on the host), so its web port
    # 8123 listens on every address of this node. The NICs are trusted (modules/server/k3s-node.nix), which
    # makes the allowedTCPPorts above irrelevant for LAN traffic, so close 8123 explicitly: only the pods
    # (Traefik, Prometheus), abaddon (its pods leave through its node IP) and this host may use it.
    # Everyone else goes through https://hass.powell.place. extraCommands run after the trusted-interface
    # accept, so the rules are inserted at the top of the chain; each -I 1 goes in front of the previous
    # one, so the order that ends up in the chain is: accept abaddon, accept pods, accept loopback, drop.
    extraCommands = ''
      iptables -w -I nixos-fw 1 -p tcp --dport 8123 -j DROP
      iptables -w -I nixos-fw 1 -p tcp --dport 8123 -s 127.0.0.0/8 -j ACCEPT
      iptables -w -I nixos-fw 1 -p tcp --dport 8123 -s 10.42.0.0/16 -j ACCEPT
      iptables -w -I nixos-fw 1 -p tcp --dport 8123 -s ${config.site.hosts.abaddon.ip} -j ACCEPT
    '';
  };
}
