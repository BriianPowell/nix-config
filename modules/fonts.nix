{ pkgs, ... }: {
  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true; # /run/current-system/sw/share/X11/fonts
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ]; # cd to fontDir then -> fc-query 'JetBrains Mono Regular Nerd Font Complete Mono.ttf' | grep '^\s\+family:' | cut -d'"' -f2
      };
    };
  };
}
