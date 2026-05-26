# iTerm2 settings for Brian_Powell (macOS).
# Full theme/profiles live in dotfiles; override per user here.
#
{ dotfiles, pkgs, ... }:
{
  programs.iterm2 = {
    enable = true;

    # Main config maintained in dotfiles (export → commit there)
    plistFile = "${dotfiles}/settings/iTerm2/com.googlecode.iterm2.plist";

    dynamicProfiles = [
      # ../../home/iterm2/dynamic-profiles/profiles.json
    ];

    # Small overrides on top of plistFile (optional)
    extraSettings = {
      Command = "${pkgs.fish}/bin/fish";
    };
  };
}
