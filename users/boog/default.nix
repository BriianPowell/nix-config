{ pkgs, config, ... }:
{
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
      openssh.authorizedKeys.keyFiles = [
        config.age.secrets."ssh/authorized_keys/boog".path
      ];
    };
  };
}
