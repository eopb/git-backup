
module Cli
    ( CliArgs
    , getCliArgs
    , userName
    , askForUserName
    )
where

import           System.Environment
import           System.IO

data GitHubUserType = User | Org

data CliArgs = CliArgs
    { userName :: Maybe String
    , userType :: GitHubUserType
    }

getCliArgs :: IO CliArgs
getCliArgs = do
    args <- getArgs
    pure $ foldl (\x y -> x) defaultArgs args
    where defaultArgs = CliArgs { userName = Nothing, userType = User }

maybeHead :: [a] -> Maybe a
maybeHead (x : _) = Just x
maybeHead []      = Nothing

askForUserName :: String -> IO String
askForUserName s = do
    putStr $ mconcat ["What github ", s, " do you want to clone: "]
    hFlush stdout
    getLine
