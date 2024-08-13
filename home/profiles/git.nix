{ dotfiles, pkgs, ... }: {
  programs.git = {
    enable = true;
  };

  home.file =
    if pkgs.system == "aarch64-darwin" then {
      ".gitconfig".source = "${dotfiles}/home/darwin.gitconfig";
      ".gitignore".source = "${dotfiles}/home/darwin.gitignore";
      "GitHub/McKinsey/alcon/.gitconfig".source = "${dotfiles}/home/alcon.gitconfig";
    } else {
      ".gitconfig".source = "${dotfiles}/home/linux.gitconfig";
    };
}
