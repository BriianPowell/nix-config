with (import <nixpkgs> { });
let
  repo = fetchFromGitHub {
    owner = "dudeofawesome";
    repo = "dotfiles";
    rev = "50d09968fd3cabf05ebee433ceab0cba98519cd5";
    # sha256 = "???";
  };
in
stdenv.mkDerivation {
  name = "install-dotfiles";
  src = repo;
  # buildPhase = ''
  #   mkdir $out
  #   wc -l ./README.md > linecount
  # '';
  installPhase = ''
    link
  '';
  system = builtins.currentSystem;
}
