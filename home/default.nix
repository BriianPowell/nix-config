{
  pkgs,
  lib,
  dotfiles,
  ...
}:
{
  imports = [
    ./profiles/config.nix
    ./profiles/fish.nix
    ./profiles/git.nix
    ./profiles/ssh.nix
    ./editor/vim.nix
  ];

  # Disable documentation generation to avoid builtins.toFile warnings
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  home = {
    stateVersion = "24.11";
  };
}
