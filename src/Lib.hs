module Lib
    ( mainTask
    )
where

import           Cli
import           FetchParse
import           Data.Text                     as T
import           System.Process
import           System.Exit
import           Data.Maybe

mainTask :: IO ()
mainTask = do
    maybeResponse <- getUserName >>= openRepoList
    response      <- case maybeResponse of
        Just a  -> pure a
        Nothing -> error "Invalid JSON"
    cloneAll response >>= print


cloneAll :: RepoList -> IO ExitCode
cloneAll (x : xs) = do
    putStr "\n\n-------------\n\n"
    currentCommand <- system . T.unpack $ command x
    case currentCommand of
        ExitSuccess   -> cloneAll xs
        ExitFailure i -> pure $ ExitFailure i
cloneAll [] = pure ExitSuccess


command :: Repo -> T.Text
command x = mconcat ["git clone ", clone_url x, " ", repoLanguage, "/", name x]
  where
    repoLanguage = T.map (\c -> if c == ' ' then '-' else c)
                         (fromMaybe "other" $ language x)

