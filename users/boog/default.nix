{ pkgs, ... }: {
  users = {
    mutableUsers = false;
    users.boog = {
      isNormalUser = true;
      home = "/home/boog";
      description = "Brian Powell";
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      passwordFile = "/etc/secrets/passwd-boog";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
      ];
    };
  };
}
