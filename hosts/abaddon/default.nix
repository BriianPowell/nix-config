{ ... }: {
  imports = [
    ../../sites/home.nix
    ./boot.nix
    ./hardware.nix
    ./system.nix
    ./tailscale.nix
    ./kubernetes.nix
  ];
}
