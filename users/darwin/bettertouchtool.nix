# BetterTouchTool preset for boog (macOS).
{ ... }:
{
  bettertouchtool = {
    enable = true;
    presetFile = ../../home/bettertouchtool/BooG.bttpreset;
    forceImport = true; # one rebuild after switching presets; set false afterward
  };
}
