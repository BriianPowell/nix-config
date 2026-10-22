# Fails if secrets/ and secrets/agenix-rules.nix disagree: every *.age file needs a
# rule (or nobody can re-key it), and every rule needs a file (or a deploy would
# reference a secret that does not exist). Evaluation only; nothing is decrypted.
{ pkgs }:
let
  inherit (pkgs) lib;
  root = ../secrets;

  # Relative paths of every *.age file under a directory.
  walk =
    dir: prefix:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        if type == "directory" then
          walk (dir + "/${name}") "${prefix}${name}/"
        else
          lib.optional (lib.hasSuffix ".age" name) "${prefix}${name}"
      ) (builtins.readDir dir)
    );

  files = walk root "";
  rules = lib.attrNames (import ../secrets/agenix-rules.nix);

  noRule = lib.subtractLists rules files;
  noFile = lib.subtractLists files rules;
  list = lib.concatStringsSep ", ";
in
assert lib.assertMsg (noRule == [ ]) "secrets without a rule in agenix-rules.nix: ${list noRule}";
assert lib.assertMsg (noFile == [ ]) "rules without a file in secrets/: ${list noFile}";
pkgs.runCommand "secrets-consistency" { } ''
  echo "${toString (builtins.length files)} secrets, all with rules" > $out
''
