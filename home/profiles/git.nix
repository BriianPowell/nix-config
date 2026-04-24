{ dotfiles, pkgs, ... }:
{
  programs.git = {
    enable = true;
  };

  home.file =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then
      {
        ".gitconfig".source = "${dotfiles}/home/darwin.gitconfig";
        ".gitignore".source = "${dotfiles}/home/darwin.gitignore";
      }
    else
      {
        ".gitconfig".source = "${dotfiles}/home/linux.gitconfig";
      };
}
