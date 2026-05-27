# iTerm2 settings for boog (macOS).
{ pkgs, ... }:
{
  iterm2 = {
    enable = true;
    plistFile = ../../home/iterm2/com.googlecode.iterm2.plist;
    extraSettings.Command = "${pkgs.fish}/bin/fish";
  };
}
