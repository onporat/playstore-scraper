{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE DeriveGeneric #-}
module Types where

import           Control.Lens
import           Data.Text          (Text (..))
import           Data.Time.Calendar (Day (..), fromGregorian)
import           Data.Time.Clock    (UTCTime (..))
import Data.Aeson
import GHC.Generics


type AppId = Text

data Proxy = Proxy
  { _proxyAddress :: !Text
  , _proxyLastUse :: UTCTime
  } -- deriving (Show, Ord)
makeLenses ''Proxy

newProxy :: Text -> Proxy
newProxy addr = Proxy addr pastTime
  where
    pastTime = UTCTime jan_1_2000_day 0
    jan_1_2000_day = fromGregorian 2000 1 1 :: Day

data AppMeta = AppMeta
  { appID    :: !AppId
  , appTitle :: !Text
  , appIcon  :: !Text
  , appEmail :: !Text
  } deriving (Show, Generic)

instance ToJSON AppMeta
