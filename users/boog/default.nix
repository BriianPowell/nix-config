{ pkgs, config, ... }:
{
  imports = [ ./authorized-keys.nix ];

  home-manager.users.boog = {
    imports = [
      ../../home
      ./git.nix
      ./home.nix
    ];
  };
  users = {
    mutableUsers = false;
    users.boog = {
      isNormalUser = true;
      home = "/home/boog";
      description = "Brian Powell";
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.age.secrets."passwords/users/boog".path;
      # Keys come from agenix → activationScripts.boogAuthorizedKeys (not keys/keyFiles here).
    };
  };
}
