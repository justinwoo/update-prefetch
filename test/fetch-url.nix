{ pkgs ? import <nixpkgs> {} }:

pkgs.fetchurl {
  url = "https://github.com/justinwoo/update-prefetch/blob/62db3a9ab3e8923f6386aa9c86a30ee1b7c21e11/package.json";
  sha256 = "1lkg1wxbc14hzqhrsqrwvb81w9ylaj24znkcz5mbid6bqh4m7nxr";
}
