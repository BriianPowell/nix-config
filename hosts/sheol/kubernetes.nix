#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
#

{ config, pkgs, lib, ... }:
let
  containerdTemplate = (builtins.readFile ./config.toml.tmpl);
in
{
  environment.systemPackages = with pkgs;
    [
      k3s
      nvidia-podman
      docker
      runc

      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
      (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (builtins.readFile ../../scripts/k3s-remove-unused-rs))
    ];

  # Enable Docker daemon.
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
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
      "--snapshotter zfs"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  # The tmpl needs the full path to the container-shim
  # https://github.com/k3s-io/k3s/issues/6518
  system.activationScripts.writeContainerdConfigTemplate = lib.mkIf (builtins.elem config.networking.hostName [ "sheol" ]) ''
    cp ${containerdTemplate} /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
  '';

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
