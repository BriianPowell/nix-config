# Git identity for boog (macOS).
{ ... }:
{
  git = {
    enable = true;
    userName = "Brian Powell";
    userEmail = "brian@powell.place";
    ignores = [ ".DS_Store" ];
    signing = {
      enable = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex";
    };
  };
}
