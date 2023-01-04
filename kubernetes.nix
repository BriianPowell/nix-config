{ config, pkgs, epkgs, ... }:
let
  # https://github.com/NixOS/nixpkgs/pull/176520
  k3s = pkgs.k3s.overrideAttrs
    (old: rec { buildInputs = old.buildInputs ++ [ pkgs.ipset ]; });
in
{
  environment.systemPackages = with pkgs; [
    crun
    docker
    iptables
    fluxcd
    helmsman
    k3s
    kubectl
    kubernetes-helm
    kubeseal
    nvidia-podman
    podman

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
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
    # https://github.com/NixOS/nixpkgs/pull/176520
    package = k3s;
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable metrics-server"
      # "--cluster-init"
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
  networking.nftables.enable = false;
  networking.firewall = {
    package = pkgs.iptables;

    allowedTCPPorts = [
      2379
      2380
      6443 # k8s API server
      8472
      10250
    ];
    allowedUDPPorts = [ 8472 ];

    trustedInterfaces = [ "cni+" ];
  };
}
