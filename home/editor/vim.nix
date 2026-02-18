{
  dotfiles,
  pkgs,
  lib,
  ...
}:
{
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

  home.activation = {
    setupVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Install Dracula theme
      if [ ! -d $HOME/.vim/pack/themes/start ]; then
        mkdir -p $HOME/.vim/pack/themes/start
        cp -r ${dotfiles}/home/.vim/pack/themes/start/dracula_pro $HOME/.vim/pack/themes/start/
      fi

      # Install vim-plug
      if [ ! -f $HOME/.vim/autoload/plug.vim ]; then
        ${pkgs.curl}/bin/curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      fi
    '';
  };
}
