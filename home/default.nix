{ ... }: {
  imports = [
    ./profiles/git.nix
    ./profiles/fish.nix
    ./editor/vim.nix
  ];

  home = {
    stateVersion = "22.11";
  };
}
