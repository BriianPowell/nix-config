{ config, pkgs, epkgs, ... }:
#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
#
let
  k3s = pkgs.k3s.overrideAttrs
    (old: rec { buildInputs = old.buildInputs ++ [ pkgs.ipset ]; });
in
{
  environment.systemPackages = with pkgs; [
    crun
    docker
    # iptables
    fluxcd
    helmsman
    k3s
    kubectl
    kubernetes-helm
    kubeseal
    nvidia-podman
    podman

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./scripts/k3s-reset-node))
  ];

  # Enable Docker daemon.
  virtualisation.docker = {
    enable = false;
    # enableNvidia = true;
    # TODO: this might not be necessary
    # extraOptions = "--default-runtime=nvidia";
    autoPrune.enable = true;
  };

  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
  };

  services.k3s = {
    package = k3s;
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--data-dir=/var/lib/rancher/k3s"
    ];
  };

  systemd.services.k3s = {
    wants = [
      "containerd.service"
      "network-online.target"
    ];
    after = [ "containerd.service" ];
  };

  # k8s doesn't work with nftables
  # networking.nftables.enable = false;
  networking.firewall = {
    # package = pkgs.iptables;

    allowedTCPPorts = [
      2379 # HA with embedded etcd
      2380 # HA with embedded etcd
      6443 # k8s API server
      10250 # Kubelet Metrics
    ];
    allowedUDPPorts = [ 8472 ];

    trustedInterfaces = [ "cni+" ];
  };
}
