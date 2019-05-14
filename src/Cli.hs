
module Cli
    ( CliArgs
    , GitHubUserType
    , getCliArgs
    , userName
    , userType
    , askForUserName
    )
where

import           System.Environment
import           System.IO

data GitHubUserType = User | Org

instance Show GitHubUserType where
    show User = "users"
    show Org  = "orgs"

data CliArgs = CliArgs
    { userName :: Maybe String
    , userType :: GitHubUserType
    } deriving (Show)

getCliArgs :: IO CliArgs
getCliArgs =
    (foldl
            (\cli arg -> case arg of
                "--user" -> CliArgs { userName = userName cli, userType = User }
                "--org" -> CliArgs { userName = userName cli, userType = Org }
                name -> CliArgs { userName = Just name, userType = userType cli }
            )
            defaultArgs
        )
        <$> getArgs
    where defaultArgs = CliArgs { userName = Nothing, userType = User }

askForUserName :: String -> IO String
askForUserName s = do
    putStr $ mconcat ["What github ", s, " do you want to clone: "]
    hFlush stdout
    getLine
