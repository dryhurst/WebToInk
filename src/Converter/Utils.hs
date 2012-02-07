module Converter.Utils(openUrl, downloadByteString, getTabs) where

import Network.HTTP.Enumerator (simpleHttp, HttpException(StatusCodeException))

import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString.Lazy.UTF8 as U

import Control.Monad.IO.Class (MonadIO)

import Control.Exception as X

import Converter.Types

openUrl :: String -> IO (Maybe String)
openUrl url = do
    bytes <- downloadByteString url 
    case bytes of
        Just bytes -> return $ Just (U.toString bytes)
        Nothing    -> return Nothing

downloadByteString :: Url -> IO (Maybe L.ByteString)
downloadByteString url = do
    byteString <- try (simpleHttp url)
    case byteString of
        Right x                                   -> return (Just x)
        Left (StatusCodeException status headers) ->
            putStrLn ("An error occured while trying to download: " ++ url)
            >> print status
            >> return Nothing

getTabs indent = replicate (indent * 2) ' '
