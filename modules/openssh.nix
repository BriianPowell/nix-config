{ config, lib, ... }:
let
  host = config.networking.hostName;
  githubSecretName = "ssh/github/${host}";
  githubSecretFile = ../secrets/ssh/github/${host}.age;
in
{
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  # Per-host GitHub deploy key for user boog (optional until secrets/ssh/github/HOST.age exists).
  age.secrets.${githubSecretName} = lib.mkIf (builtins.pathExists githubSecretFile) {
    file = githubSecretFile;
    owner = "boog";
    group = "users";
    mode = "0600";
    path = "/home/boog/.ssh/github";
  };
}
