{ ... }: {
  imports = [
    ./profiles/git.nix
    ./profiles/fish.nix
    ./editor/vim.nix
  ];

  home = {
    stateVersion = "23.05";
  };
}
