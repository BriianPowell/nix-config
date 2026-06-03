{ ... }: {
  imports = [
    ./options.nix
    ./defaults.nix
    ./system.nix
    ./brew.nix
    ./docs.nix
    ./security.nix
  ];
}
