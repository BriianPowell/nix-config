{ pkgs, ... }:
{
  home-manager.users.Brian_Powell = import ../../home;
  users = {
    users.Brian_Powell = {
      home = "/Users/Brian_Powell";
      # name = "boog";
      # description = "Brian Powell";
      shell = pkgs.fish;
      # openssh.authorizedKeys.keys = [
      #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
      # ];
    };
  };
}
