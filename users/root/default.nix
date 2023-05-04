{ config, ... }: {
  users = {
    users.root.passwordFile = config.age.secrets."passwords/users/root".path;
  };
}
