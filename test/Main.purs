module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class.Console (log)
import Main (runUpdate)

main :: Effect Unit
main = Aff.launchAff_ do
  _ <- runUpdate "ci.nix"
  _ <- runUpdate "test/fetch-github.nix"
  _ <- runUpdate "test/fetch-url.nix"
  _ <- runUpdate "test/fetch-tarball.nix"
  _ <- runUpdate "test/fetch-nested-set.nix"
  log "done"
