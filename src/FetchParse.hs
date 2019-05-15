module FetchParse
    ( RepoList
    , Repo
    , openRepoList
    , language
    , name
    , cloneUrl
    )
where

import qualified Data.ByteString.Lazy.Char8    as LC
import           Data.Text                     as T
import           Cli
import           Data.Aeson
import           Network.HTTP.Simple
import           GHC.Generics

type RepoList = [Repo]
type StringOr = Either T.Text

data Repo = Repo
    { name      :: T.Text
    , language  :: Maybe T.Text
    , cloneUrl :: T.Text
    } deriving (Show, Generic)
instance FromJSON Repo where
    parseJSON (Object v) =
        Repo <$> v .: "name" <*> v .: "language" <*> v .: "clone_url"
    parseJSON _ = error "Faild to decode JSON"


openRepoList :: String -> GitHubUserType -> IO (StringOr RepoList)
openRepoList user gitHubUserType =
    (>>= decodeRepoList) <$> openRepoListJson user gitHubUserType

openRepoListJson :: String -> GitHubUserType -> IO (StringOr LC.ByteString)
openRepoListJson user gitHubUserType = do
    correctStatus <- in200s <$> status
    if correctStatus
        then Right . getResponseBody <$> openedPage
        else Left . T.pack <$> statusError
  where
    openedPage =
        addRequestHeader "User-Agent" "git-backup"
            <$> parseRequest url
            >>= httpLBS
    statusError = do
        statusStr <- show <$> status
        pure
            (mconcat
                [ "Cant open url \""
                , url
                , "\" exited with response code "
                , statusStr
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

in200s :: (Ord a, Num a) => a -> Bool
in200s x = 200 <= x && x < 300

decodeRepoList :: LC.ByteString -> StringOr RepoList
decodeRepoList = setError "Faild to decode JSON" . decode

setError :: e -> Maybe k -> Either e k
setError e m = case m of
    Just k  -> Right k
    Nothing -> Left e


