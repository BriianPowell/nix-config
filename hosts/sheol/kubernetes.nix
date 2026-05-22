#
# Resources
# https://github.com/NixOS/nixpkgs/issues/181790
# https://github.com/moduon/nixpkgs/blob/60e0d3d73670ef8ddca24aa546a40283e3838e69/nixos/modules/services/cluster/k3s/default.nix
# https://docs.k3s.io/advanced#configuring-containerd
# https://github.com/k3s-io/k3s/issues/6518
#

{ pkgs, lib, ... }:
let
  toolkitTools = pkgs.nvidia-container-toolkit.tools;
  # CDI mode in config.toml requires the full runtime wrapper, not .legacy (see nvidia.nix).
  nvidiaContainerRuntime = "${toolkitTools}/bin/nvidia-container-runtime";
  nvidiaContainerRuntimeCdi = "${toolkitTools}/bin/nvidia-container-runtime.cdi";

  containerdConfigTemplate = ''
    {{ template "base" . }}

    [plugins."io.containerd.grpc.v1.cri"]
      enable_cdi = true

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "${nvidiaContainerRuntime}"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-cdi]
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-cdi.options]
      BinaryName = "${nvidiaContainerRuntimeCdi}"
  '';

  containerdTemplate = pkgs.writeText "config.toml.tmpl" containerdConfigTemplate;
in
{
  environment.systemPackages = with pkgs; [
    k3s
    docker
    runc

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
    (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (
      builtins.readFile ../../scripts/k3s-remove-unused-rs
    ))
  ];

  # https://nixos.wiki/wiki/Nvidia#NVIDIA_Docker_not_Working
  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
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
      "--kube-proxy-arg --metrics-bind-address=0.0.0.0" # Required for prometheus monitoring of kube-proxy
      "--kube-controller-manager-arg --bind-address=0.0.0.0" # Required for prometheus monitoring of kube-controller-manager
      "--kube-scheduler-arg --bind-address=0.0.0.0" # Required for prometheus monitoring of kube-scheduler
      "--data-dir /var/lib/rancher/k3s"
    ];
  };

  system.activationScripts.writeContainerdConfigTemplate = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/rancher/k3s/agent/etc/containerd
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
      8472 # k3s, flannel: required if using multi-node for inter-node networking
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
