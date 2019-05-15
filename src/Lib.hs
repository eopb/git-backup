module Lib
    ( mainTask
    )
where

import           Cli
import           FetchParse
import           Data.Text                     as T
import           System.Process
import           System.Exit

mainTask :: IO ()
mainTask = do
    cliArgs <- getCliArgs
    let gitHubUserType    = userType cliArgs
    let gitHubUserTypeStr = getGitHubUserTypeStr gitHubUserType
    putStrLn $ mconcat ["Using ", gitHubUserTypeStr, " mode"]
    userNameVar <- case userName cliArgs of
        Just x  -> pure x
        Nothing -> askForUserName gitHubUserTypeStr
    putStrLn $ mconcat ["Opening ", gitHubUserTypeStr, " ", userNameVar]
    response <- openRepoList userNameVar gitHubUserType
    case response of
        Right k -> do
            result <- cloneAll k
            putStrLn $ case result of
                ExitSuccess   -> "All clones completed successfully"
                ExitFailure _ -> "Clone Failed: Exiting"
        Left e -> putStrLn $ T.unpack e

getGitHubUserTypeStr :: GitHubUserType -> String
getGitHubUserTypeStr x = case x of
    User -> "user"
    Org  -> "organization"

cloneAll :: RepoList -> IO ExitCode
cloneAll (x : xs) = do
    putStr "\n-------------\n\n"
    currentCommand <- system . T.unpack $ command x
    case currentCommand of
        ExitSuccess   -> cloneAll xs
        ExitFailure i -> pure $ ExitFailure i
cloneAll [] = pure ExitSuccess

command :: Repo -> T.Text
command repo = mconcat
    ["git clone ", cloneUrl repo, " ", repoLanguage, "/", name repo]
  where
    repoLanguage = maybe "other"
                         (T.map (\c -> if c == ' ' then '-' else c))
                         (language repo)




