{ pkgs ? import <nixpkgs> {} }:

let
  easy-ps = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "6d0f4ae1d75d4b03fee2cc75af746e1ed556556e";
    sha256 = "0l7z03z00alyfa1pb1aaj9dcc9liqjbby9647bgxyclwiknpnqy7";
  });

in pkgs.stdenv.mkDerivation {
  name = "travis-shell";

  buildInputs = [ pkgs.nodejs pkgs.nix-prefetch-git easy-ps.purs easy-ps.spago ];
}
