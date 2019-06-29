module Update where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class.Console (error)
import FormatNix (Expr(..))
import Node.ChildProcess as CP
import PrefetchGit (readPrefetchGitResult)
import Sunde as S

data FetchType
  = GitHub { owner :: String, repo :: String }
  | Url { url :: String }
  | Tarball { name :: String, url :: String }

data Update
  = GitHubUpdate { owner :: String, repo :: String, rev :: String, sha256 :: String }
  | UrlUpdate { url :: String, sha256 :: String }
  | TarballUpdate { name :: String, url :: String, sha256 :: String }

readFetchType :: Array Expr -> Maybe FetchType
readFetchType attrs
  | 4 == Array.length attrs
  , binds <- Array.mapMaybe getBind attrs
  , Just owner <- stripQuotes <$> match "owner" binds
  , Just repo <- stripQuotes <$> match "repo" binds
  , _ <- match "rev" binds
  , _ <- match "sha256" binds
  = Just $ GitHub { owner, repo }
  | 2 == Array.length attrs
  , binds <- Array.mapMaybe getBind attrs
  , Just url <- stripQuotes <$> match "url" binds
  , _ <- match "sha256" binds
  = Just $ Url { url }
  | 3 == Array.length attrs
  , binds <- Array.mapMaybe getBind attrs
  , Just name <- stripQuotes <$> match "name" binds
  , Just url <- stripQuotes <$> match "url" binds
  , _ <- match "sha256" binds
  = Just $ Tarball { name, url }
  | otherwise = Nothing

getUpdate :: FetchType -> Aff Update
getUpdate (GitHub {owner, repo}) = do
  error $ "updating GitHub fetch: " <> owner <> "/" <> repo
  json <- runCommand
    { cmd: "nix-prefetch-git"
    , args: [ "https://github.com/" <> owner <> "/" <> repo, "--quiet" ]
    }
  {rev,sha256} <- readPrefetchGitResult json
  pure $ GitHubUpdate { owner, repo, rev, sha256}
getUpdate (Url {url}) = do
  error $ "updating url fetch: " <> url
  sha256 <- String.trim <$> runCommand
    { cmd: "nix-prefetch-url"
    , args: [ url ]
    }
  pure $ UrlUpdate { url, sha256 }
getUpdate (Tarball {name, url}) = do
  error $ "updating Tarball fetch: " <> url
  sha256 <- String.trim <$> runCommand
    { cmd: "nix-prefetch-url"
    , args: [ url, "--unpack" ]
    }
  pure $ TarballUpdate { name, url, sha256 }

makeAttrSet :: Update -> Expr
makeAttrSet (GitHubUpdate {owner, repo, rev, sha256}) =
  AttrSet
    [ Bind (AttrPath "owner") (StringValue $ show owner)
    , Bind (AttrPath "repo") (StringValue $ show repo)
    , Bind (AttrPath "rev") (StringValue $ show rev)
    , Bind (AttrPath "sha256") (StringValue $ show sha256)
    ]
makeAttrSet (UrlUpdate {url, sha256}) =
  AttrSet
    [ Bind (AttrPath "url") (StringValue $ show url)
    , Bind (AttrPath "sha256") (StringValue $ show sha256)
    ]
makeAttrSet (TarballUpdate {name, url, sha256}) =
  AttrSet
    [ Bind (AttrPath "name") (StringValue $ show name)
    , Bind (AttrPath "url") (StringValue $ show url)
    , Bind (AttrPath "sha256") (StringValue $ show sha256)
    ]

type Pair = { path :: String , value :: String }

getBind :: Expr -> Maybe Pair
getBind (Bind (AttrPath path) (StringValue value)) = Just { path, value }
getBind _ = Nothing

match :: String -> Array Pair -> Maybe String
match path pairs = _.value <$> Array.find (eq path <<< _.path) pairs

stripQuotes :: String -> String
stripQuotes = String.replaceAll (String.Pattern "\"") (String.Replacement "")

runCommand :: { cmd :: String, args :: Array String } -> Aff String
runCommand {cmd, args} = do
  result <- S.spawn { cmd, args, stdin: Nothing } CP.defaultSpawnOptions
  case result.exit of
    CP.Normally 0 -> do
      pure result.stdout
    _ -> do
      error $ "error running :" <> cmd
      error $ show result.exit
      error result.stderr
      Aff.throwError $ Aff.error result.stderr

updateFetchAttrs :: Expr -> Aff Expr
updateFetchAttrs (AttrSet attrs) = do
  case readFetchType attrs of
    Just fetchType -> do
      update <- getUpdate fetchType
      pure $ makeAttrSet update
    Nothing -> do
      pure (AttrSet attrs)
updateFetchAttrs e = immediate updateFetchAttrs e

immediate :: forall f. Applicative f => (Expr -> f Expr) -> Expr -> f Expr
immediate f (Expression xs) = Expression <$> traverse f xs
immediate f (Unary str expr) = Unary str <$> f expr
immediate f (Binary a str b) = Binary <$> f a <*> pure str <*> f b

immediate f (Let xs ys) = Let <$> traverse f xs <*> traverse f ys
immediate f (If a b c) = If <$> f a <*> f b <*> f c
immediate f (AttrSet xs) = AttrSet <$> traverse f xs
immediate f (RecAttrSet xs) = RecAttrSet <$> traverse f xs
immediate f (List xs) = List <$> traverse f xs
immediate f (Inherit xs) = Inherit <$> traverse f xs
immediate f (Attrs xs) = Attrs <$> traverse f xs
immediate f (Formals xs) = Formals <$> traverse f xs

immediate f (Formal e mE) = Formal e <$> traverse f mE
immediate f (Parens e) = Parens <$> f e

immediate f (Function a b) = Function <$> f a <*> f b
immediate f (SetFunction a b) = SetFunction <$> f a <*> f b
immediate f (App a b) = App <$> f a <*> f b
immediate f (Select a b) = Select <$> f a <*> f b
immediate f (Bind a b) = Bind <$> f a <*> f b
immediate f (With a b) = With <$> f a <*> f b

immediate f e@(AttrPath string) = pure e
immediate f e@(Uri string) = pure e
immediate f e@(Comment string) = pure e
immediate f e@(Spath string) = pure e
immediate f e@(Path string) = pure e
immediate f e@(StringValue string) = pure e
immediate f e@(Integer string) = pure e
immediate f e@(StringIndented string) = pure e
immediate f e@(Identifier string) = pure e

immediate f Ellipses = pure Ellipses
