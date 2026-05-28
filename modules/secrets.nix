{ ... }: {
  age.secrets."passwords/users/boog".file = ../secrets/passwords/users/boog.age;
  age.secrets."passwords/users/root".file = ../secrets/passwords/users/root.age;
  age.secrets."passwords/k3s/token".file = ../secrets/passwords/k3s/token.age;

  # SSH login for user boog: nixos_admin public key(s) in authorized_keys/boog.plain → boog.age.
  age.secrets."ssh/authorized_keys/boog" = {
    file = ../secrets/ssh/authorized_keys/boog.age;
    # Static path on /boot so initrd SSH can read keys on the next rebuild.
    path = "/etc/ssh/authorized_keys/boog";
    symlink = false;
    mode = "0444";
  };
}
