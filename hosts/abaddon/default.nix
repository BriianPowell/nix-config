{ ... }: {
  imports = [
    ../../sites/home.nix
    ./boot.nix
    ./hardware.nix
    ./system.nix
    ./kubernetes.nix
  ];
}
