{ config, ... }:
{
  # `root` is already a trusted nix user by default, so it is not listed here.
  users.users.root.hashedPasswordFile = config.age.secrets."passwords/users/root".path;
}
