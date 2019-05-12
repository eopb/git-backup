

module Main where

import           Lib
import qualified Data.ByteString               as B
import qualified Data.ByteString.Char8         as BC
import qualified Data.ByteString.Lazy          as L
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


main :: IO ()
main = do
    responce <- openRepoList
    let responce2 = decodeRepoList (getResponseBody responce)
    print (responce2)

openRepoList :: IO (Response LC.ByteString)
openRepoList = do
    request <- (addRequestHeader "User-Agent" "git-backup")
        <$> parseRequest "https://api.github.com/users/ethanboxx/repos"
    httpLBS request

decodeRepoList :: LC.ByteString -> Maybe RepoList
decodeRepoList x = decode x
