{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    k3s

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
    (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (builtins.readFile ../../scripts/k3s-remove-unused-rs))
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://10.0.2.10:6443";
    token = config.age.secrets."passwords/k3s/token".path;
    extraFlags = toString [
      "--node-name abaddon"
      "--node-ip 10.0.2.11"
      "--node-external-ip 10.0.2.11"
      "--server https://10.0.2.10:6443"
      "--data-dir /var/lib/rancher/k3s"
    ];
  };
}
