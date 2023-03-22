{ ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
    ./kubernetes.nix
    ./system.nix
    ./zfs.nix
  ];
}
