# Vim: vimrc, dracula_pro theme, vim-plug bootstrap.
#
# Per user: vim.enable = true;
#
{ config, lib, pkgs, ... }:
let
  cfg = config.vim;
  vimDir = ../vim;
in
{
  options.vim = {
    enable = lib.mkEnableOption "vim configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.vim = {
      enable = true;
      defaultEditor = true;
      extraConfig = ''
        source $HOME/.vim/vimrc
      '';
    };

    home.file.".vim/vimrc".source = "${vimDir}/vimrc";

    home.activation.setupVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.vim/pack/themes/start ]; then
        mkdir -p $HOME/.vim/pack/themes/start
        cp -r ${vimDir}/dracula_pro $HOME/.vim/pack/themes/start/
      fi

      if [ ! -f $HOME/.vim/autoload/plug.vim ]; then
        ${pkgs.curl}/bin/curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      fi
    '';
  };
}
