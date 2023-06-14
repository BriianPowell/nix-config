{ ... }: {
  imports = [
    ./system.nix
    ./nix.nix
    ./brew.nix
    ./docs.nix
    ./security.nix
  ];
}
