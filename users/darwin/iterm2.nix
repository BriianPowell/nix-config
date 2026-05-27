# iTerm2 settings for boog (macOS).
{ pkgs, ... }:
{
  iterm2 = {
    enable = true;
    plistFile = ../../home/iterm2/com.googlecode.iterm2.plist;
    dynamicProfiles = [
      ../../home/iterm2/BooG.json
    ];
    extraSettings.Command = "${pkgs.fish}/bin/fish";
  };
}
