{ pkgs, ... }: {
  fonts = {
    fontDir.enable = true; # /run/current-system/sw/share/X11/fonts
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
