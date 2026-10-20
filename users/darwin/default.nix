{ pkgs, config, ... }:
let
  # The one place the account name is written: users/darwin/machine.nix.
  name = config.machine.username;
in
{
  imports = [
    ./machine.nix
  ];

  home-manager.users.${name} = {
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

  nix.settings.trusted-users = [ name ];

  users = {
    users.${name} = {
      home = "/Users/${name}";
      shell = pkgs.fish;
    };
  };
}
