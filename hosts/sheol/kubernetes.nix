#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
#

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # crun
    # docker
    # podman
    # nvidia-podman
    k3s

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

  # virtualisation.podman = {
  #   enable = true;
  #   enableNvidia = true;
  # };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--cluster-init"
      "--flannel-backend host-gw"
      "--disable traefik"
      "--disable metrics-server"
      "--data-dir=/var/lib/rancher/k3s"
      "--etcd-expose-metrics"
      "--kube-proxy-arg --metrics-bind-address=0.0.0.0"
      "--kube-controller-manager-arg --bind-address=0.0.0.0"
      "--kube-scheduler-arg --bind-address=0.0.0.0"
    ];
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
