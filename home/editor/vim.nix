{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  home.file = {
    ".vim/vimrc".source = "${dotfiles}/home/.vim/vimrc";
  };

  environment = {
    variables = {
      MYVIMRC = "$HOME/.vim/vimrc";
    };
  };
}
