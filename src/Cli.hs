
module Cli
    ( getUserName
    )
where

import           System.Environment
import           System.IO

getUserName :: IO String
getUserName = do
    args <- getArgs
    case maybeHead args of
        Just x  -> pure x
        Nothing -> do
            putStr "What github user do you want to clone: "
            hFlush stdout
            getLine

maybeHead :: [a] -> Maybe a
maybeHead (x : xs) = Just x
maybeHead []       = Nothing
