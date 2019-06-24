module PrefetchGit where

import Prelude

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class.Console (error)
import Simple.JSON as JSON

type PrefetchGitResult =
  { url :: String
  , rev :: String
  , sha256 :: String
  }

readPrefetchGitResult :: String -> Aff PrefetchGitResult
readPrefetchGitResult json = do
  case JSON.readJSON json of
    Right r -> pure r
    Left e -> do
      error $ "error in reading nix-prefetch-git results"
      Aff.throwError $ Aff.error $ show e
