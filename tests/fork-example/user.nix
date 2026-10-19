# A made-up account for the fork acceptance check: what a fork's users/<name> needs
# at minimum. No secrets, no personal files.
{ pkgs, ... }:
{
  home-manager.users.example.imports = [ ../../home ];
  nix.settings.trusted-users = [ "example" ];
  users.users.example = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "wheel" ];
  };
}
