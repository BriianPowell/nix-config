{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
}
