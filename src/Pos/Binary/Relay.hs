{-# LANGUAGE BangPatterns #-}

-- | Pos.Util.Relay serialization instances

module Pos.Binary.Relay () where

import           Universum

import           Pos.Binary.Class                 (Bi (..))
import           Pos.Binary.Crypto                ()
import           Pos.Crypto                       (hash)
import           Pos.Ssc.GodTossing.Types.Message (GtMsgContents (..))
import           Pos.Txp.Types.Communication      (TxMsgContents (..))
import           Pos.Update.Core                  (UpdateProposal, UpdateVote (..))
import           Pos.Util.Relay                   (DataMsg (..), InvMsg (..), ReqMsg (..))

instance (Bi tag, Bi key) => Bi (InvMsg key tag) where
    put InvMsg {..} = put imTag >> put imKeys
    get = liftM2 InvMsg get get

instance (Bi tag, Bi key) => Bi (ReqMsg key tag) where
    put ReqMsg {..} = put rmTag >> put rmKeys
    get = liftM2 ReqMsg get get

instance Bi (DataMsg GtMsgContents) where
    put (DataMsg dmContents) = put dmContents
    get = DataMsg <$> get

instance Bi (DataMsg TxMsgContents) where
    put (DataMsg (TxMsgContents dmTx dmWitness dmDistr)) =
        put dmTx >> put dmWitness >> put dmDistr
    get = do
      conts <- TxMsgContents <$> get <*> get <*> get
      pure $ DataMsg conts

instance Bi (DataMsg (UpdateProposal, [UpdateVote])) where
    put (DataMsg dmContents) = put dmContents
    get = do
        c@(up, votes) <- get
        let !id = hash up
        unless (all ((id ==) . uvProposalId) votes) $
            fail "get@DataMsg@Update: vote's uvProposalId must be equal UpId"
        pure $ DataMsg c

instance Bi (DataMsg UpdateVote) where
    put (DataMsg uv) = put uv
    get = DataMsg <$> get
