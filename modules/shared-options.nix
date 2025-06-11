{ config
, lib
, ...
}:
{
  options.trustedUsers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ "boog" "root" ];
    description = ''
      List of users that are trusted to run Nix commands.
      This is important for security, as it prevents untrusted users from modifying the Nix store.
    '';
  };
}
