{ pkgs, ... }: {
  users = {
    users.louis = {
      isNormalUser = true;
      home = "/home/louis";
      description = "Louis Orleans";
      shell = pkgs.fish;
      extraGroups = [ "wheel" "docker" ];
      # passwordFile = "/etc/secrets/passwd-louis";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXZP1BhadI1hxgexqZX4p5TCARSxnSwC7zXFoXWtKeH"
      ];
    };
  };
}
