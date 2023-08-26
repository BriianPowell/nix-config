#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
#

{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    k3s
    nvidia-podman
    # crun
    # docker
    # podman

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
    (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (builtins.readFile ../../scripts/k3s-remove-unused-rs))
  ];

  # Enable Docker daemon.
  # virtualisation.docker = {
  #   enable = false;
  #   # enableNvidia = true;
  #   # TODO: this might not be necessary
  #   # extraOptions = "--default-runtime=nvidia";
  #   autoPrune.enable = true;
  # };

  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
  };

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs; [
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in
      {
        plugins."io.containerd.grpc.v1.cri" = {
          # TODO: this may or may not be upstreamed already
          cni = {
            bin_dir = "${fullCNIPlugins}/bin";
            conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
          };
        };
      };
  };

  systemd.services.containerd.serviceConfig = {
    ExecStartPre = [
      "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs moriyya/containerd"
    ];
  };

  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = toString [
      "--node-name sheol"
      "--node-ip 10.0.2.10"
      "--node-external-ip 10.0.2.10"
      "--flannel-backend host-gw"
      "--disable traefik"
      "--disable metrics-server"
      "--etcd-expose-metrics"
      "--kube-proxy-arg --metrics-bind-address=0.0.0.0"
      "--kube-controller-manager-arg --bind-address=0.0.0.0"
      "--kube-scheduler-arg --bind-address=0.0.0.0"
      "--data-dir /var/lib/rancher/k3s"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  systemd.services.k3s = {
    wants = [ "containerd.service" ];
    after = [ "containerd.service" ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      2379 # HA with embedded etcd
      2380 # HA with embedded etcd
      6443 # k8s API server
      10250 # Kubelet Metrics
      21063 # Home Assistant on k3s
    ];

    allowedUDPPorts = [
      8472
      5353 # Home Assistant on k3s
    ];

    trustedInterfaces = [
      "enp6s0"
      "enp0s31f6"
      "cni0"
      "lo"
    ];
  };
}
