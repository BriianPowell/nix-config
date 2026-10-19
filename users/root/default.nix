{ config, lib, ... }:
{
  # `root` is already a trusted nix user by default, so it is not listed here.
  age.secrets."passwords/users/root".file = ../../secrets/passwords/users/root.age;

  # mkDefault so a host that cannot decrypt it (WSL) can set it to null.
  users.users.root.hashedPasswordFile = lib.mkDefault config.age.secrets."passwords/users/root".path;
}
