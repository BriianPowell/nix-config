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

  services.k3s = {
    enable = true;
    role = "server";
  };
}
