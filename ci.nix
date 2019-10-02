{ pkgs ? import <nixpkgs> {} }:

let
  easy-ps = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "cc7196bff3fdb5957aabfe22c3fa88267047fe88";
      sha256 = "1xfl7rnmmcm8qdlsfn3xjv91my6lirs5ysy01bmyblsl10y2z9iw";
    }
  ) {
    inherit pkgs;
  };

in
pkgs.stdenv.mkDerivation {
  name = "travis-shell";

  buildInputs = [ pkgs.nodejs pkgs.nix-prefetch-git easy-ps.purs easy-ps.spago ];
}
