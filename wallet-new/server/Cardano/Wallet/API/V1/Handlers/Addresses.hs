{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}
module Cardano.Wallet.API.V1.Handlers.Addresses where

import           Universum

import           Cardano.Wallet.API.Request
import           Cardano.Wallet.API.Response
import qualified Cardano.Wallet.API.V1.Addresses as Addresses
import           Cardano.Wallet.API.V1.Types
import           Pos.Core (decodeTextAddress)

import           Servant
import           Test.QuickCheck (arbitrary, generate, vectorOf)

handlers :: Server Addresses.API
handlers =  listAddresses
       :<|> newAddress
       :<|> verifyAddress

listAddresses :: RequestParams
              -> Handler (WalletResponse [Address])
listAddresses RequestParams {..} = do
    addresses <- liftIO $ generate (vectorOf 2 arbitrary)
    return WalletResponse {
              wrData = addresses
            , wrStatus = SuccessStatus
            , wrMeta = Metadata $ PaginationMetadata {
                        metaTotalPages = 1
                      , metaPage = 1
                      , metaPerPage = 20
                      , metaTotalEntries = 2
                      }
            }

newAddress :: Address -> Handler (WalletResponse Address)
newAddress a = return $ single a

-- | Verifies that an address is base58 decodable.
verifyAddress :: Text -> Handler (WalletResponse AddressValidity)
verifyAddress address =
    case decodeTextAddress address of
        Right _ ->
            return $ single $ AddressValidity True
        Left _  ->
            return $ single $ AddressValidity False
