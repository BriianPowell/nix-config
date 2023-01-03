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
    cri-tools

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

  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        # FIXME: upstream
        cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
      };
    };
  };

  services.k3s = {
    # https://github.com/NixOS/nixpkgs/pull/176520
    package = k3s;
    enable = true;
    role = "server";
    extraFlags = toString [
      # "--flannel-backend=host-gw"
      "--disable metrics-server"
      # "--cluster-init"
      "--data-dir=/var/lib/rancher/k3s"
      # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  systemd.services.k3s = {
    wants = [ "containerd.service" ];
    after = [ "containerd.service" ];
  };

  # k8s doesn't work with nftables
  networking.nftables.enable = false;
  networking.firewall = {
    package = pkgs.iptables-legacy;

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
