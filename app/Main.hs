module Main where

import           Lib
import qualified Data.ByteString.Lazy.Char8    as LC
import           Data.Text                     as T
import           Data.Aeson
import           Network.HTTP.Simple
import           GHC.Generics
import           System.Process
import           System.Exit
import           Data.Maybe

type RepoList = [Repo]

data Repo = Repo
    { name      :: T.Text
    , language  :: Maybe T.Text
    , clone_url :: T.Text
    } deriving (Show, Generic)
instance FromJSON Repo


main :: IO ()
main = do
    print "What github user do you want to clone"
    user     <- getLine
    responce <- openRepoList user
    responce <- case responce of
        Just a  -> pure a
        Nothing -> error "Invalid JSON"
    cloneAll responce >>= print


cloneAll :: RepoList -> IO ExitCode
cloneAll (x : xs) = do
    print (command x)
    currentCommand <- system (T.unpack (command x))
    case currentCommand of
        ExitSuccess   -> cloneAll xs
        ExitFailure i -> pure (ExitFailure i)
cloneAll [] = pure ExitSuccess


command :: Repo -> T.Text
command x = mconcat ["git clone ", clone_url x, " ", repoLanguage, "/", name x]
  where
    repoLanguage = T.map (\x -> if x == ' ' then '-' else x)
                         (fromMaybe "other" (language x))
openRepoList :: String -> IO (Maybe RepoList)
openRepoList user =
    (openRepoListJson user) >>= (pure . decodeRepoList . getResponseBody)

openRepoListJson :: String -> IO (Response LC.ByteString)
openRepoListJson user = do
    request <- addRequestHeader "User-Agent" "git-backup" <$> parseRequest
        (mconcat ["https://api.github.com/users/", user, "/repos"])
    httpLBS request

decodeRepoList :: LC.ByteString -> Maybe RepoList
decodeRepoList = decode
