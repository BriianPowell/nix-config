{
  pkgs,
  lib,
  dotfiles,
  ...
}:
{
  imports = [
    ./modules/iterm2.nix
    ./modules/rectangle.nix
    ./profiles/config.nix
    ./profiles/fish.nix
    ./profiles/git.nix
    ./profiles/ssh.nix
    ./editor/vim.nix
  ];

  # macOS only; each user overrides in users/darwin/<user>.nix
  programs.rectangle.enable = pkgs.stdenv.hostPlatform.isDarwin;
  programs.iterm2.enable = pkgs.stdenv.hostPlatform.isDarwin;

  # Disable documentation generation to avoid builtins.toFile warnings
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  home = {
    stateVersion = "24.11";
  };
}
