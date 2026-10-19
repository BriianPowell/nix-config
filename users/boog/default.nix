{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./authorized-keys.nix
    ./github-deploy-key.nix
  ];

  home-manager.users.boog = {
    imports = [
      ../common/home.nix
      ./home.nix
    ];
  };
  nix.settings.trusted-users = [ "boog" ];

  age.secrets."passwords/users/boog".file = ../../secrets/passwords/users/boog.age;

  users = {
    mutableUsers = false;
    users.boog = {
      isNormalUser = true;
      home = "/home/boog";
      description = "Brian Powell";
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      # mkDefault so a host that cannot decrypt it (WSL) can set it to null.
      hashedPasswordFile = lib.mkDefault config.age.secrets."passwords/users/boog".path;
      # Keys come from agenix → activationScripts.boogAuthorizedKeys (not keys/keyFiles here).
    };
  };
}
