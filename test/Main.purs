module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class.Console (log)
import Main (runUpdate)

main :: Effect Unit
main = Aff.launchAff_ do
  runUpdate "ci.nix"
  runUpdate "test/fetch-github.nix"
  runUpdate "test/fetch-url.nix"
  runUpdate "test/fetch-tarball.nix"
  runUpdate "test/fetch-nested-set.nix"
  log "done"
