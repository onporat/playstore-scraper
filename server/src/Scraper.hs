{-# LANGUAGE OverloadedStrings #-}

module Scraper where
--  ( scrapID
--  ) where

import           Types
import           Control.Exception    as X
import qualified Data.ByteString.Lazy as L
import           Data.Text            (Text (..))
import qualified Data.Text            as T
import           Network.HTTP.Conduit (simpleHttp)
import           Text.HTML.DOM        (parseLBS)
import           Text.XML.Cursor      (Cursor, attribute, attributeIs, child,
                                       content, element, fromDocument, ($//),
                                       (&//), (&|), (>=>))

statusExceptionHandler ::  SomeException -> IO L.ByteString
statusExceptionHandler e = return L.empty

-- The URL we're going to search
url :: String
url = "http://127.0.0.1:9000/GooglePlay.html?id="
--url = "https://play.google.com/store/apps/details?hl=en&id="

findIconNodes :: Cursor -> [Cursor]
findIconNodes = element "img" >=> attributeIs "alt" "Cover art"

extractIconData :: Cursor -> Text
extractIconData = T.concat . (attribute "src")

findTitleNodes :: Cursor -> [Cursor]
findTitleNodes = element "div" >=> attributeIs "class" "id-app-title" >=> child

extractTitleData :: Cursor -> Text
extractTitleData = T.concat . content

findEmailNodes :: Cursor -> [Cursor]
findEmailNodes = element "a" >=> attributeIs "class" "dev-link"

extractEmailData :: Cursor -> Text
extractEmailData =
   T.drop 7 -- remove "mailto:"
 . T.concat
 . (filter (T.isPrefixOf "mailto:"))
 . (attribute "href")


-- Process the list of data elements
processData :: Monad m => AppId -> Cursor -> m AppMeta
processData id cursor = do
  let title = T.concat $ cursor $// findTitleNodes &| extractTitleData
  let icon = T.concat $ cursor $// findIconNodes &| extractIconData
  let email = T.concat $ cursor $// findEmailNodes &| extractEmailData
  return (AppMeta id title icon email)

cursorFor :: String -> IO (Maybe Cursor)
cursorFor u = do
    page <- (simpleHttp u) `X.catch` statusExceptionHandler
    case page of x | x == L.empty -> return Nothing
                   | otherwise    -> return $ Just $ fromDocument $ parseLBS page

scrapID :: Text -> Proxy -> IO (Maybe AppMeta)
scrapID id prx = do  -- proxy is ignored
  mCursor <- cursorFor (url ++ (T.unpack id))
  case mCursor of
    Just cursor -> return $ processData id cursor
    Nothing -> return Nothing

