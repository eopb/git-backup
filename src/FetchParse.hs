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
import           Cli
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


openRepoList :: String -> GitHubUserType -> IO (Maybe RepoList)
openRepoList user gitHubUserType =
    openRepoListJson user gitHubUserType
        >>= (pure . decodeRepoList . getResponseBody)

openRepoListJson :: String -> GitHubUserType -> IO (Response LC.ByteString)
openRepoListJson user gitHubUserType =
    addRequestHeader "User-Agent" "git-backup" <$> parseRequest url >>= httpLBS
  where
    url =
        mconcat
            [ "https://api.github.com/"
            , show gitHubUserType
            , "/"
            , user
            , "/repos"
            ]


decodeRepoList :: LC.ByteString -> Maybe RepoList
decodeRepoList = decode

