{ config, ... }: {
  users = {
    users.root.hashedPasswordFile = config.age.secrets."passwords/users/root".path;
  };
}
