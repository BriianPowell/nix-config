{ config, pkgs, epkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    crun
    docker
    k3s
    kubectl
    podman
  ];

  # Enable Docker daemon.
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true;
    autoPrune.enable = true;
  };

  virtualisation.containerd = {
    enable = true;
    # settings = {
    #   version = 2;
    #   plugins."io.containerd.grp.v1.cri" = {
    #     cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
    #   };
    # };
  };

  services.k3s = {
    enable = true;
    role = "server";
    # docker = true;
    extraFlags = "--container-runtime-endpoint unix:///run/containerd/containerd.sock";
  };

  systemd.services.k3s = {
    wants = [ "containerd.service" ];
    after = [ "containerd.service" ];
  };
}
