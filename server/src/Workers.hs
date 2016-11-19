module Workers where

import Types
import           Control.Concurrent.BoundedChan --(newBoundedChan, readChan, writeChan)
import Scraper
import           Data.Time.Clock       (UTCTime (..), getCurrentTime)
import           Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import Control.Concurrent (forkIO, threadDelay)
import Control.Monad (forM_, void, forever, when)
import Data.Aeson (encode)
import qualified Data.ByteString.Lazy as LB

startPersister :: IO (BoundedChan AppMeta)
startPersister = do
  q  <- newBoundedChan 10000
  void $ forkIO $ forever $ do -- start logger service
    app <- readChan q
    LB.appendFile "apps.json" (encode app `LB.append` (LB.singleton 0x0a))
  return q


srapWorker :: BoundedChan AppId
           -> BoundedChan Proxy
           -> BoundedChan AppMeta
           -> BoundedChan Proxy
           -> IO()
srapWorker idQ freshQ persistQ tiredQ =
  void $ forkIO $ forever $ do
    id <- readChan idQ
    p <- readChan freshQ
    mApp <- scrapID id p
    case mApp of
      Just app -> writeChan persistQ app
      Nothing -> return ()
    now <- getCurrentTime
    writeChan tiredQ (p { _proxyLastUse = now })


restingWorker :: Int -> Int -> IO (BoundedChan Proxy, BoundedChan Proxy)
restingWorker proxyQueueSize restSeconds = do
  freshQ <- newBoundedChan proxyQueueSize
  tiredQ <- newBoundedChan proxyQueueSize

  void $ forkIO $ forever $ do
    p <- readChan tiredQ
    now <- getCurrentTime
    let timeDiff = (utcTimeToSec (_proxyLastUse p) + restSeconds)
                 - (utcTimeToSec now)
    when (timeDiff > 0) $
      threadDelay (timeDiff * 1000000)

    writeChan freshQ p

  return (freshQ, tiredQ)


utcTimeToSec :: UTCTime -> Int
utcTimeToSec u = floor $ utcTimeToPOSIXSeconds u :: Int
