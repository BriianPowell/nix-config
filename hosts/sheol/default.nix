{ ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
    ./kubernetes.nix
    ./nvidia.nix
    ./system.nix
    ./zfs.nix
  ];
}
