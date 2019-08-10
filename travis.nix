{ pkgs ? import <nixpkgs> {} }:

let
  easy-ps = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "1d85bbc58ff7ed5401f6a9b39d25a9e9b4cfdd61";
    sha256 = "1nvbfl82shs71c4gnyx1yaifvzhr60d325ax129n3ih58d2f7sc7";
  }) {
    inherit pkgs;
  };

in pkgs.stdenv.mkDerivation {
  name = "travis-shell";

  buildInputs = [ pkgs.nodejs pkgs.nix-prefetch-git easy-ps.purs easy-ps.spago ];
}
