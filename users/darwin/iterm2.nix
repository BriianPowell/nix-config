# iTerm2 settings for boog (macOS).
{ pkgs, ... }:
{
  iterm2 = {
    enable = true;
    plistFile = ../../home/iterm2/com.googlecode.iterm2.plist;
    dynamicProfiles = [
      ../../home/iterm2/BooG.json
    ];
    extraSettings = {
      "Custom Command" = "Yes";
      # Homebrew fish; nixpkgs fish is broken on aarch64-darwin (invalid signature).
      Command = "/opt/homebrew/bin/fish";
      # PostScript name for JetBrainsMonoNerdFontMono-Regular.ttf (terminal mono).
      "Normal Font" = "JetBrainsMonoNFM-Regular 12";
      "Non Ascii Font" = "JetBrainsMonoNFM-Regular 12";
    };
  };
}
