module FetchParse
    ( RepoList
    , Repo
    , openRepoList
    , language
    , name
    , clone_url
    )
where

import qualified Data.ByteString.Lazy.Char8    as LC
import           Data.Text                     as T
import           Data.Aeson
import           Network.HTTP.Simple
import           GHC.Generics

type RepoList = [Repo]

data Repo = Repo
    { name      :: T.Text
    , language  :: Maybe T.Text
    , clone_url :: T.Text
    } deriving (Show, Generic)
instance FromJSON Repo


openRepoList :: String -> IO (Maybe RepoList)
openRepoList user =
    openRepoListJson user >>= (pure . decodeRepoList . getResponseBody)

openRepoListJson :: String -> IO (Response LC.ByteString)
openRepoListJson user = do
    request <- addRequestHeader "User-Agent" "git-backup" <$> parseRequest
        (mconcat ["https://api.github.com/users/", user, "/repos"])
    httpLBS request

decodeRepoList :: LC.ByteString -> Maybe RepoList
decodeRepoList = decode

