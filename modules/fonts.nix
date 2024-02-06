{ pkgs, ... }: {
  fonts =
    if (pkgs.system == "aarch64-darwin") then {
      fontDir.enable = true; # /run/current-system/sw/share/X11/fonts
      fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
    } else {
      fontDir.enable = true;
      packages = with pkgs;
        [
          (nerdfonts.override {
            fonts = [ "JetBrainsMono" ];
          })
        ];
    };
}
