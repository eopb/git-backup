

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
    responce <- openRepoList
    responce <- case responce of
        Just a  -> pure a
        Nothing -> error "Invalid JSON"
    cloneAll responce >>= print


cloneAll :: RepoList -> IO ExitCode
cloneAll (x : xs) = do
    currentCommand <- system (T.unpack (command x))
    case currentCommand of
        ExitSuccess   -> cloneAll xs
        ExitFailure i -> pure (ExitFailure i)

command :: Repo -> T.Text
command x = mconcat ["git clone ", clone_url x, " ", repoLanguage, "/", name x]
    where repoLanguage = fromMaybe "other" $ language x

openRepoList :: IO (Maybe RepoList)
openRepoList = openRepoListJson >>= (pure . decodeRepoList . getResponseBody)

openRepoListJson :: IO (Response LC.ByteString)
openRepoListJson = do
    request <- addRequestHeader "User-Agent" "git-backup"
        <$> parseRequest "https://api.github.com/users/ethanboxx/repos"
    httpLBS request

decodeRepoList :: LC.ByteString -> Maybe RepoList
decodeRepoList = decode
