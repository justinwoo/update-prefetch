# https://github.com/justinwoo/easy-purescript-nix/blob/7255d015b80d28c7c6db655dda215535cb2d4b41/psc-package2nix.nix

{ pkgs ? import <nixpkgs> {} }:

import (pkgs.fetchFromGitHub {
  owner = "justinwoo";
  repo = "psc-package2nix";
  rev = "da2368886961e08c5f0b5b3f78aa485fed116d8e";
  sha256 = "05akkd3p9hs03iia9g2swscms7sd0pviflj8rjq1hiak8ajgx6qm";
}) {
  inherit pkgs;
}
