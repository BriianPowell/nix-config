{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    k3s

    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ../../scripts/k3s-reset-node))
    (pkgs.writeShellScriptBin "k3s-remove-unused-rs" (builtins.readFile ../../scripts/k3s-remove-unused-rs))
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = lib.mkDefault "https://10.0.2.10:6443";
    token = lib.mkDefault config.age.secrets."passwords/k3s/token".path;
    extraFlags = toString [
      "--node-ip 10.0.2.11"
      "--data-dir /var/lib/rancher/k3s"
    ];
  };
}
