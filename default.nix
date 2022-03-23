let
  pkgs = import (builtins.fetchGit { 
    name = "nixpkgs-latex";
    url = https://github.com/nixos/nixpkgs-channels/;
    ref = "refs/heads/nixos-unstable";
    # git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable
    rev = "4762fba469e2baa82f983b262e2c06ac2fdaae67";
  }) {};
in

with pkgs;

stdenv.mkDerivation {
  name = "paper";
  src = ./src;

  TEXMFVAR = "/tmp/texmf";

  preBuild = ''
    mkdir -p $TEXMFVAR
  '';

  installPhase = ''
    mkdir -p $out
    cp paper.pdf $out
  '';

  buildInputs = [
    (texlive.combine {
      inherit (texlive) scheme-small luatex biblatex latexmk biber lualatex-math stix2-otf;
    })
  ];
}
