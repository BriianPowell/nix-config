{ dotfiles, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      source $HOME/.vim/vimrc
    '';
  };

  home.file = {
    ".vim/vimrc".source = "${dotfiles}/home/.vim/vimrc";
  };
}


#
# Plugin Install
# vim then :PluginInstall
# or
# vim +PluginInstall +qall
#
