{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TemplateHaskell            #-}
module Server where

import           Control.Applicative
import           Control.Concurrent.BoundedChan
import           Control.Lens
import           Data.Monoid
import           Control.Monad
import           Control.Monad.Trans
import           Data.Text                      (Text (..))
import qualified Data.Text as T
import           Data.Text.Encoding
import           Snap
import           Data.Time.Clock       (UTCTime (..), getCurrentTime)
import Types
import Scraper
import Workers


writeHandler :: BoundedChan Text -> Snap ()
writeHandler idQ = do
  mId <- getParam "id"
  case mId of
    Nothing -> writeBS "must POST id param body"
    Just id -> do
      liftIO $ writeChan idQ (decodeUtf8 id)
      -- debug writeBS id


site :: BoundedChan Text -> Snap ()
site idQ = route
  [ ("write", writeHandler idQ)
  , ("", (writeBS "Post data to /write id=com.some.app\n"))
  ]


main :: IO ()
main = do
  -- config
  let jobQueueSize = 5000
      numberOfProxies = 50
      proxyRestSeconds = 10
      numberOfScrapWorkers = 4


  idQ <- newBoundedChan jobQueueSize :: IO (BoundedChan AppId)
  toPresistQ  <- startPersister
  (freshProxyQ, tiredProxyQ) <- restingWorker numberOfProxies proxyRestSeconds

  -- init proxy queue
  forM_ [1..numberOfProxies] $ \id -> do
    let pid = "proxy" ++ show id
    writeChan freshProxyQ (newProxy (T.pack pid))

  -- start scrap workers
  forM_ [1..numberOfScrapWorkers] $ \num -> do
    srapWorker idQ freshProxyQ toPresistQ tiredProxyQ

  quickHttpServe $ site idQ

