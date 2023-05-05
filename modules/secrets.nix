{ ... }: {
  age.secrets."passwords/users/boog".file = ../secrets/passwords/users/boog.age;
  age.secrets."passwords/users/root".file = ../secrets/passwords/users/root.age;
}
