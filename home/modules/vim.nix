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

    # Old activations may have copied dracula_pro as root-owned files; use `run` (as the HM user).
    home.activation.removeLegacyVimDracula = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      DRACULA="$HOME/.vim/pack/themes/start/dracula_pro"
      if [ -e "$DRACULA" ] && [ ! -L "$DRACULA" ]; then
        run chmod -R u+w "$DRACULA" 2>/dev/null || true
        run rm -rf "$DRACULA" 2>/dev/null || true
        if [ -e "$DRACULA" ]; then
          echo "vim: could not remove read-only legacy dracula_pro. Run once, then rebuild:"
          echo "  chmod -R u+w '$DRACULA' && rm -rf '$DRACULA'"
        fi
      fi
      run find "$HOME/.vim/pack/themes/start" -name '*.backup' -delete 2>/dev/null || true
    '';

    home.file = {
      ".vim/vimrc" = {
        source = "${vimDir}/vimrc";
        force = true;
      };
      ".vim/pack/themes/start/dracula_pro" = {
        source = "${vimDir}/dracula_pro";
        recursive = true;
        force = true;
      };
    };

    home.activation.setupVimPlug = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f $HOME/.vim/autoload/plug.vim ]; then
        run ${lib.getExe pkgs.curl} -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      fi
    '';
  };
}
