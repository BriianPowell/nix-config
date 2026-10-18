# My home network. A fork replaces this file (or adds its own next to it) and
# imports it from its hosts.
_: {
  site = {
    gateway = "10.0.2.1";
    dns = [ "10.0.2.1" ];
    initrdAuthorizedKeys = [ (import ../secrets/keys.nix).nixosAdmin ];
  };
}
