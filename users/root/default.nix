{ ... }: {
  users = {
    users.root.passwordFile = "/etc/secrets/passwd-root";
  };
}
