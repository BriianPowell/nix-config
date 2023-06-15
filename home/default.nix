{ pkgs, lib, dotfiles, ... }: {
  imports = [
    ./profiles/git.nix
    ./profiles/fish.nix
    ./editor/vim.nix
  ];

  home = {
    stateVersion = "23.05";
    activation.vim = lib.hm.dag.entryAfter [ ''writeBoundary'' ] ''
      if ! [ -d $HOME/.vim/pack/themes/start ]; then
        mkdir -p $HOME/.vim/pack/themes/start
        cp -r ${dotfiles}/home/.vim/pack/themes/start/dracula_pro $HOME/.vim/pack/themes/start/
      fi
    '';
  };
}
