{ pkgs ? import ./nixpkgs.nix {} }:

let
  n2n = import ./node2nix.nix {
    inherit pkgs;
  };

in
pkgs.runCommand "update-prefetch" {
  name = "update-prefetch";

  buildInputs = [ pkgs.makeWrapper ];
} ''
  target=$out/bin/update-prefetch
  mkdir -p $out/bin

  ln -s ${n2n.package.outPath}/bin/update-prefetch $target

  wrapProgram $target --prefix PATH : ${pkgs.lib.makeBinPath [
  n2n.package
  pkgs.nix-prefetch-git
  pkgs.nix
  pkgs.which
]}
''
