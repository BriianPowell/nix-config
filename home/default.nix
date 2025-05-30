{ pkgs, lib, dotfiles, ... }: {
  imports = [
    ./profiles/config.nix
    ./profiles/fish.nix
    ./profiles/git.nix
    ./profiles/ssh.nix
    ./editor/vim.nix
  ];

  home = {
    stateVersion = "24.11";
    activation = {
      vim = lib.hm.dag.entryAfter [ ''writeBoundary'' ] ''
        if ! [ -d $HOME/.vim/pack/themes/start ]; then
          mkdir -p $HOME/.vim/pack/themes/start
          cp -r ${dotfiles}/home/.vim/pack/themes/start/dracula_pro $HOME/.vim/pack/themes/start/
        fi
        if ! [ -d $HOME/.vim/bundle/Vundle.vim ]; then
          mkdir -p $HOME/.vim/bundle
          ${pkgs.git}/bin/git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
        fi
      '';
    };
  };
}
