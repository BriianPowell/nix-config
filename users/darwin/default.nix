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
      # name = "Brian Powell";
      # description = "";
      shell = pkgs.fish;
      # openssh.authorizedKeys.keys = [
      #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
      # ];
    };
  };
}
