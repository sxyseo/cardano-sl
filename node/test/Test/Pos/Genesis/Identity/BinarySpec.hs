-- | This module tests Binary instances.

module Test.Pos.Genesis.Identity.BinarySpec
       ( spec
       ) where

import           Test.Hspec         (Spec, describe)
import           Universum

import           Pos.Arbitrary.Core ()
import qualified Pos.Genesis        as T

import           Test.Pos.Util      (binaryTest)

spec :: Spec
spec = describe "Genesis" $ do
    describe "Bi instances" $ do
        binaryTest @T.BalanceDistribution