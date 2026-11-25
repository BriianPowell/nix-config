# Dracula PRO for vim. The theme is licensed (personal use, three computers), so it is not in
# this repo: the archive is added to each machine's nix store by hand, and the build fails
# with the instructions below until that is done.
#
# The archive is the `themes/vim` folder of the Dracula PRO download plus its `license.md`,
# under one top-level `dracula-pro/` directory. Rebuild it, and change `hash`, when the theme
# is updated.
{ pkgs }:
let
  archive = pkgs.requireFile {
    name = "dracula-pro-vim.tar.gz";
    hash = "sha256-ltb3Yg4TtoiS2PxMbgZTmTqREuUJoDBRl/BYObdym+Y=";
    message = ''
      Dracula PRO is licensed and is not kept in this repository.
      Copy dracula-pro-vim.tar.gz (kept in Nextcloud, "Dracula PRO") to this machine, then run:

        nix-store --add-fixed sha256 dracula-pro-vim.tar.gz

      The licence allows three computers; see users/common/home.nix for which hosts get it.
    '';
  };
in
pkgs.runCommand "dracula-pro-vim" { } ''
  mkdir -p $out
  tar -xzf ${archive} --strip-components=1 -C $out
''
