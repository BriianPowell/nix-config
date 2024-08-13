{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    k3s

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
    (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (builtins.readFile ../../scripts/k3s-remove-unused-rs))
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://10.0.2.10:6443";
    tokenFile = config.age.secrets."passwords/k3s/token".path;
    extraFlags = toString [
      "--node-name abaddon"
      "--node-ip 10.0.2.11"
      "--node-external-ip 10.0.2.11"
      "--data-dir /var/lib/rancher/k3s"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      2379 # HA with embedded etcd
      2380 # HA with embedded etcd
      6443 # k8s API server
      10250 # Kubelet Metrics
    ];

    allowedUDPPorts = [
      8472
    ];

    trustedInterfaces = [
      "enp0s31f6"
      "cni0"
      "lo"
    ];
  };
}
