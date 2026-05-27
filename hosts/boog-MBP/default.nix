{ ... }: {
  imports = [
    ./options.nix
    ./system.nix
    ./brew.nix
    ./docs.nix
    ./security.nix
  ];
}
