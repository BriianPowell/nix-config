{ ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
    ./kubernetes.nix
    ./nvidia.nix
    ./system.nix
    ./unpack-media.nix
    ./zfs.nix
  ];
}
