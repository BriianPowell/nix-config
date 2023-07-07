{ ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
    ./system.nix
    ./kubernetes.nix
  ];
}
