# BetterTouchTool preset for Boog (macOS).
{ ... }:
{
  programs.bettertouchtool = {
    enable = true;
    presetFile = ../../home/bettertouchtool/bttdata.json;
  };
}
