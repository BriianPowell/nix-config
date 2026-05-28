{ pkgs, ... }:
{
  imports = [
    ./machine.nix
  ];

  home-manager.users.Brian_Powell = {
    imports = [
      ../../home
      ./git.nix
      ./home.nix
      ./rectangle.nix
      ./iterm2.nix
      ./bettertouchtool.nix
      ./displayplacer.nix
    ];
  };

  users = {
    users.Brian_Powell = {
      home = "/Users/Brian_Powell";
      shell = pkgs.fish;
    };
  };
}
