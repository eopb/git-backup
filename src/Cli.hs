
module Cli
    ( CliArgs
    , GitHubUserType(User, Org)
    , getCliArgs
    , userName
    , userType
    , askForUserName
    )
where

import           System.Environment
import           System.IO
import           Control.Lens

data GitHubUserType = User | Org

instance Show GitHubUserType where
    show User = "users"
    show Org  = "orgs"

data CliArgs = CliArgs
    { _userName :: Maybe String
    , _userType :: GitHubUserType
    } deriving (Show)
makeLenses ''CliArgs


defaultArgs :: CliArgs
defaultArgs = CliArgs { _userName = Nothing, _userType = User }

getCliArgs :: IO CliArgs
getCliArgs =
    foldl
            (\cli arg -> case arg of
                "--user" -> cli & userType .~ User
                "--org"  -> cli & userType .~ Org
                name     -> cli & userName ?~ name
            )
            defaultArgs
        <$> getArgs


askForUserName :: String -> IO String
askForUserName s = do
    putStr $ mconcat ["What github ", s, " do you want to clone: "]
    hFlush stdout
    getLine
