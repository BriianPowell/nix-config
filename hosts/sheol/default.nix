{ ... }: {
  imports = [
    ../../sites/home.nix
    ./boot.nix
    ./hardware.nix
    ./kubernetes.nix
    ./media-user.nix
    ./nvidia.nix
    ./system.nix
    ./unpack-media.nix
    ./zfs.nix
  ];
}
