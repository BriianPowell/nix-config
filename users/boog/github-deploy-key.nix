{ config, lib, ... }:
let
  host = config.networking.hostName;
  githubSecretName = "ssh/github/${host}";
  githubSecretFile = ../../secrets/ssh/github/${host}.age;
in
{
  # Per-host GitHub deploy key for boog (optional until secrets/ssh/github/HOST.age exists).
  age.secrets.${githubSecretName} = lib.mkIf (builtins.pathExists githubSecretFile) {
    file = githubSecretFile;
    owner = "boog";
    group = "users";
    mode = "0600";
    path = "/home/boog/.ssh/github";
  };
}
