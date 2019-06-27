# Update-Prefetch

Update fetch SHAs in Nix derivations with less pain.

## Usage

Given some files with fetch expressions:

```bash
import (pkgs.fetchFromGitHub {
  owner = "justinwoo";
  repo = "psc-package2nix";
  rev = "da2368886961e08c5f0b5b3f78aa485fed116d8e";
  sha256 = "05akkd3p9hs03iia9g2swscms7sd0pviflj8rjq1hiak8ajgx6qm";
}) {
  inherit pkgs;
}

pkgs.fetchurl {
  url = "https://github.com/justinwoo/update-prefetch/blob/62db3a9ab3e8923f6386aa9c86a30ee1b7c21e11/package.json";
  sha256 = "1lkg1wxbc14hzqhrsqrwvb81w9ylaj24znkcz5mbid6bqh4m7nxr";
}
```

You can update these kinds of files easily:

```bash
$ update-prefetch test/fetch-github.nix
updating GitHub fetch: justinwoo/psc-package2nix
updated test/fetch-github.nix.
```
