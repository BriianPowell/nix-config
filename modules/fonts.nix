{ pkgs, ... }: {
  fonts = {
    packages = with pkgs;
      [
        # nerd-fonts.jetbrains-mono
        (nerdfonts.override {
          fonts = [ "JetBrainsMono" ];
        })
      ];
  };
}
