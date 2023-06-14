{ pkgs, ... }: {
  fonts = {
    fontDir.enable = true; # /run/current-system/sw/share/X11/fonts
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
