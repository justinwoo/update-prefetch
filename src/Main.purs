module Main where

import Prelude

import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Monoid (guard)
import Data.Traversable (for, traverse)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import FormatNix (TreeSitterParser, children, mkParser, nixLanguage, parse, printExpr, readNode, rootNode)
import Node.ChildProcess (Exit(..))
import Node.ChildProcess as CP
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Sunde as S
import Update (updateFetchAttrs)

foreign import argv :: Array String
foreign import _processExit :: Int -> Effect Unit

processExit :: Int -> Aff Unit
processExit = liftEffect <<< _processExit

parser :: TreeSitterParser
parser = mkParser nixLanguage

main :: Effect Unit
main = launchAff_ do
  case Array.index argv 2 of
    Nothing -> error needFileArg
    Just fileName -> runUpdate fileName

runUpdate :: String -> Aff Unit
runUpdate fileName = do
  contents <- readTextFile UTF8 fileName
  let root = rootNode $ parse parser contents
  let eNodes = readNode `traverse` children root
  case eNodes of
    Right nodes -> do
      nodes' <- for nodes \node -> do
        updateFetchAttrs node

      let output = Array.intercalate "\n" $ printExpr <$> nodes'

      writeTextFile UTF8 fileName output

      let cmd = "nixpkgs-fmt"
      checkNixpkgsFmt <- S.spawn { cmd: "which", args: [cmd], stdin: Nothing } CP.defaultSpawnOptions
      case checkNixpkgsFmt.exit of
        Normally 0 -> do
          let args = [fileName]
          out <- S.spawn { cmd, args, stdin: Nothing } CP.defaultSpawnOptions
          error "ran nixpkgs-fmt:"
          error out.stderr
        _ -> pure unit

      error $ "updated " <> fileName <> "."
    Left _ -> do
      error "encountered errors in parsing input file."
      processExit 1

needFileArg :: String
needFileArg = """
You must provide an argument for an expression file to read and write to.

E.g. update-prefetch my-expression.nix
"""
