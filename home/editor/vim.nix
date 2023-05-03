{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    # defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nerdtree
      papercolor-theme
      rainbow_parentheses
      vim-airline
      vim-prettier
    ];
  };
}
