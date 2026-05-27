{
  ...
}:
{
  imports = [
    ./modules/atuin.nix
    ./modules/bettertouchtool.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/iterm2.nix
    ./modules/rectangle.nix
    ./modules/ssh.nix
    ./modules/tooling.nix
    ./modules/vim.nix
  ];

  # Disable documentation generation to avoid builtins.toFile warnings
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  home = {
    stateVersion = "24.11";
  };
}
