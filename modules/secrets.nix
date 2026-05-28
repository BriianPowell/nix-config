{ ... }: {
  age.secrets."passwords/users/boog".file = ../secrets/passwords/users/boog.age;
  age.secrets."passwords/users/root".file = ../secrets/passwords/users/root.age;
  age.secrets."passwords/k3s/token".file = ../secrets/passwords/k3s/token.age;

  age.secrets."ssh/authorized_keys/boog".file = ../secrets/ssh/authorized_keys/boog.age;
}
