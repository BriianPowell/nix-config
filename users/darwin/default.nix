{ pkgs, ... }:
{
  imports = [
    ./machine.nix
  ];

  home-manager.users.Brian_Powell = {
    imports = [
      ../common/home.nix
      ./git.nix
      ./home.nix
      ./rectangle.nix
      ./iterm2.nix
      ./bettertouchtool.nix
      ./displayplacer.nix
    ];
  };

  nix.settings.trusted-users = [ "Brian_Powell" ];

  users = {
    users.Brian_Powell = {
      home = "/Users/Brian_Powell";
      shell = pkgs.fish;
    };
  };
}
