{ pkgs, dotfiles, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  home.file = {
    ".vim/vimrc".source = "${dotfiles}/home/.vim/vimrc";
  };
}
