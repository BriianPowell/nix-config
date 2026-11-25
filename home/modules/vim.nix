# Vim: vimrc, colour themes, vim-plug bootstrap.
#
# Per user: vim.enable = true;
# Personal files: vim.vimrcFile = ./vimrc; vim.themes.<name> = ./<name>;
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vim;
in
{
  options.vim = {
    enable = lib.mkEnableOption "vim configuration";

    vimrcFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "vimrc linked to ~/.vim/vimrc and sourced from ~/.vimrc. Null leaves vim at its defaults.";
    };

    themes = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Vim colour scheme directories, each linked to ~/.vim/pack/themes/start/<name>.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vim = {
      enable = true;
      defaultEditor = true;
      extraConfig = lib.optionalString (cfg.vimrcFile != null) ''
        source $HOME/.vim/vimrc
      '';
    };

    # Old activations may have copied a theme as root-owned files; use `run` (as the HM user).
    home.activation.removeLegacyVimThemes = lib.mkIf (cfg.themes != { }) (
      lib.hm.dag.entryBefore [ "writeBoundary" ] (
        lib.concatMapStrings (name: ''
          THEME="$HOME/.vim/pack/themes/start/${name}"
          if [ -e "$THEME" ] && [ ! -L "$THEME" ]; then
            run chmod -R u+w "$THEME" 2>/dev/null || true
            run rm -rf "$THEME" 2>/dev/null || true
            if [ -e "$THEME" ]; then
              echo "vim: could not remove read-only legacy ${name}. Run once, then rebuild:"
              echo "  chmod -R u+w '$THEME' && rm -rf '$THEME'"
            fi
          fi
        '') (lib.attrNames cfg.themes)
        + ''
          run find "$HOME/.vim/pack/themes/start" -name '*.backup' -delete 2>/dev/null || true
        ''
      )
    );

    home.file =
      lib.optionalAttrs (cfg.vimrcFile != null) {
        ".vim/vimrc" = {
          source = cfg.vimrcFile;
          force = true;
        };
      }
      // lib.mapAttrs' (
        name: dir:
        lib.nameValuePair ".vim/pack/themes/start/${name}" {
          source = dir;
          recursive = true;
          force = true;
        }
      ) cfg.themes;

    home.activation.setupVimPlug = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f $HOME/.vim/autoload/plug.vim ]; then
        run ${lib.getExe pkgs.curl} -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      fi
    '';
  };
}
