# Recipients for encrypt.sh (all public keys from secrets.nix).
let
  secrets = import ../../secrets.nix;
  names = builtins.attrNames secrets;
  allKeys = builtins.concatLists (
    map (
      n:
      let
        v = secrets.${n};
      in
      if builtins.isList v then v else v.publicKeys or [ ]
    ) names
  );
  unique = builtins.attrNames (builtins.listToAttrs (map (k: { name = k; value = null; }) allKeys));
in
builtins.concatStringsSep "\n" unique
