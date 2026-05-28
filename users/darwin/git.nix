# Git identity for boog (macOS).
let
  keys = import ../../secrets/ssh/keys.nix;
in
{
  git = {
    enable = true;
    userName = "Brian Powell";
    userEmail = "brian@powell.place";
    ignores = [ ".DS_Store" ];
    signing = {
      enable = true;
      key = keys.gitSigning;
    };
  };
}
