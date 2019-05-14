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


openRepoList :: String -> GitHubUserType -> IO (Either T.Text RepoList)
openRepoList user gitHubUserType = do
    openRepoListJson user gitHubUserType >>= (\x -> pure (x >>= decodeRepoList))

openRepoListJson :: String -> GitHubUserType -> IO (Either T.Text LC.ByteString)
openRepoListJson user gitHubUserType = do
    correctStatus <- (== 200) <$> status
    if correctStatus
        then (Right . getResponseBody) <$> openedPage
        else ((Left . T.pack) <$> statusError)
  where
    openedPage :: IO (Response LC.ByteString)
    openedPage =
        (addRequestHeader "User-Agent" "git-backup" <$> parseRequest url)
            >>= httpLBS
    statusError :: IO String
    statusError = do
        status <- show <$> status
        pure
            (mconcat
                [ "Cant open url \""
                , url
                , "\" exited with response code "
                , status
                ]
            )

    status = getResponseStatusCode <$> openedPage
    url =
        mconcat
            [ "https://api.github.com/"
            , show gitHubUserType
            , "/"
            , user
            , "/repos"
            ]


decodeRepoList :: LC.ByteString -> Either T.Text RepoList
decodeRepoList = setError "Faild to decode JSON" . decode

setError :: e -> Maybe k -> Either e k
setError e m = case m of
    Just k  -> Right k
    Nothing -> Left e
