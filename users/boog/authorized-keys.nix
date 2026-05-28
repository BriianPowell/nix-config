# Install login keys from agenix at activation (no plaintext .pub in the flake).
{ config, ... }:
let
  secret = config.age.secrets."ssh/authorized_keys/boog".path;
in
{
  system.activationScripts.boogAuthorizedKeys = {
    text = ''
      if [ ! -f "${secret}" ]; then
        echo "agenix secret missing: ssh/authorized_keys/boog" >&2
        exit 1
      fi
      install -d -m 700 -o boog -g users /home/boog/.ssh
      cp "${secret}" /home/boog/.ssh/authorized_keys
      chmod 600 /home/boog/.ssh/authorized_keys
      chown boog:users /home/boog/.ssh/authorized_keys
    '';
    deps = [
      "users"
      "agenix"
    ];
  };
}
