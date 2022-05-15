{ stdenv }:

with (import <nixpkgs> { });
let
  repo = fetchFromGitHub {
    owner = "dudeofawesome";
    repo = "dotfiles";
    rev = "50d09968fd3cabf05ebee433ceab0cba98519cd5";
    sha256 = "???";
    leaveDotGit = true;
  };
in
stdenv.mkDerivation {
  name = "dotfiles";
  version = "0.0.1";
  src = repo;
  # buildPhase = ''
  #   mkdir $out
  #   wc -l ./README.md > linecount
  # '';
  installPhase = ''
    link
    fisher update
  '';
  system = builtins.currentSystem;
}
