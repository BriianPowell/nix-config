{ pkgs, config, ... }: {
  home-manager.users.boog = import ../../home;
  users = {
    mutableUsers = false;
    users.boog = {
      isNormalUser = true;
      home = "/home/boog";
      description = "Brian Powell";
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.age.secrets."passwords/users/boog".path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
      ];
      ignoreShellProgramCheck = true;
    };
  };
}
