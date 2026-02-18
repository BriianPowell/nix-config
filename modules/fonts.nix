{ pkgs, lib, ... }:
{
  fonts = {
    packages =
      with pkgs;
      (lib.optionals pkgs.stdenv.isDarwin [
        # macOS uses nerd-fonts directly
        nerd-fonts.jetbrains-mono
      ])
      ++ (lib.optionals pkgs.stdenv.isLinux [
        # NixOS uses override to save space
        (nerdfonts.override {
          fonts = [ "JetBrainsMono" ];
        })
      ]);
  };
}
