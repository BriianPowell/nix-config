{ pkgs, ... }: {
  home-manager.users.boog = import ../../home;
  users = {
    users.boog = {
      home = "/Users/boog";
      # name = "boog";
      # description = "Brian Powell";
      shell = pkgs.fish;
      # openssh.authorizedKeys.keys = [
      #  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
      # ];
      ignoreShellProgramCheck = true;
    };
  };
}
