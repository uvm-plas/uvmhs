module UVMHS.Init 
  (module UVMHS.Init
  ,module GHC.Exts
  ,module Prelude
  ) where

import Prelude(Bool(..),($),undefined,otherwise,IO,Eq((==)),Ord(compare),Show(show),Ordering(..))
import GHC.Exts (type Constraint)

import qualified Prelude as HS

import qualified Data.Int as HS
import qualified Data.Word as HS
import qualified Numeric.Natural as HS

import qualified Data.Text as Text

import qualified Data.Set as Set
import qualified Data.Map.Strict as Map
import qualified Data.Sequence as Sequence

-- 0[R]: $
-- 1[L]: :*
-- 2[R]: ≫= →
-- 3[I]: ≡
-- 4[L]: +
-- 5[L]: ×
-- 6[L]: ∘
-- 7[L]: #,^
-- 8[*]: :&
-- 9[L]: ⋅

infixl 1 :*
infixr 2 ⇰
infixl 4 ∨,⩔
infixl 5 ∧,⩓
infixl 6 ∘
infixr 8 :&

type ℕ = HS.Natural
type ℕ64 = HS.Word64
type ℕ32 = HS.Word32
type ℕ16 = HS.Word16
type ℕ8  = HS.Word8
type ℤ = HS.Integer
type ℤ64 = HS.Int64
type ℤ32 = HS.Int32
type ℤ16 = HS.Int16
type ℤ8  = HS.Int8
type ℚ = HS.Rational
type 𝔻 = HS.Double

type ℂ = HS.Char
type 𝕊 = Text.Text

data Void
type 𝔹 = HS.Bool
data a ∨ b = Inl a | Inr b
  deriving (Eq,Ord,Show)
data a ∧ b = a :* b
  deriving (Eq,Ord,Show)
data 𝑂 a = None | Some a
  deriving (Eq,Ord,Show)
data 𝐿 a = Nil | a :& 𝐿 a
  deriving (Eq,Ord)
newtype 𝐼 a = 𝐼 { un𝐼 ∷ ∀ b. (a → b → b) → b → b }
data 𝑆 a where 𝑆 ∷ ∀ s a. s → (s → 𝑂 (a ∧ s)) → 𝑆 a
newtype 𝑄 a = 𝑄 { un𝑄 ∷ Sequence.Seq  a }
  deriving (Eq,Ord)
newtype 𝑃 a = 𝑃 { un𝑃 ∷ Set.Set a }
  deriving (Eq,Ord)
newtype k ⇰ v = 𝐷 { un𝐷 ∷ Map.Map k v }
  deriving (Eq,Ord)

data W (c ∷ Constraint) where W ∷ (c) ⇒ W c

data Nat = Z | S Nat

data P (a ∷ k) = P

-- Syntax --

fromString ∷ [ℂ] → 𝕊
fromString = Text.pack

fromInteger ∷ ℤ → ℕ
fromInteger = HS.fromIntegral

negate ∷ ℕ → ℤ
negate n = HS.negate (HS.fromIntegral n)

fromRational ∷ HS.Rational → 𝔻
fromRational = HS.fromRational

fail ∷ [ℂ] → m a
fail = HS.error

-- Conversion --

𝕟64 ∷ ℕ → ℕ64
𝕟64 = HS.fromIntegral

𝕟32 ∷ ℕ → ℕ32
𝕟32 = HS.fromIntegral

𝕟16 ∷ ℕ → ℕ16
𝕟16 = HS.fromIntegral

𝕟8 ∷ ℕ → ℕ8
𝕟8 = HS.fromIntegral

𝕫 ∷ ℕ → ℤ
𝕫 = HS.fromIntegral

𝕫64 ∷ ℕ → ℤ64
𝕫64 = HS.fromIntegral

𝕫32 ∷ ℕ → ℤ32
𝕫32 = HS.fromIntegral

𝕫16 ∷ ℕ → ℤ16
𝕫16 = HS.fromIntegral

𝕫8 ∷ ℕ → ℤ8
𝕫8 = HS.fromIntegral

chars ∷ 𝕊 → [ℂ]
chars = Text.unpack

fromChars ∷ [ℂ] → 𝕊
fromChars = Text.pack

with ∷ W c → ((c) ⇒ a) → a
with W x = x

error ∷ 𝕊 → a
error = HS.error ∘ chars

-- Functions --

id ∷ a → a
id x = x

const ∷ a → b → a
const x _ = x

(∘) ∷ (b → c) → (a → b) → a → c
(g ∘ f) x = g (f x)

(∘∘) ∷ (c → d) → (a → b → c) → (a → b → d)
(∘∘) = (∘) ∘ (∘)

flip ∷ (a → b → c) → (b → a → c)
flip f y x = f x y

rotateR ∷ (a → b → c → d) → (c → a → b → d)
rotateR f c a b = f a b c

rotateL ∷ (a → b → c → d) → (b → c → a → d)
rotateL f b c a = f a b c

mirror ∷ (a → b → c → d) → (c → b → a → d)
mirror f c b a = f a b c

on ∷ (b → b → c) → (a → b) → (a → a → c)
on p f x y = p (f x) (f y)

-- Bools --

not ∷ 𝔹 → 𝔹
not True = False
not False = True

(⩓) ∷ 𝔹 → 𝔹 → 𝔹
True ⩓ x = x
x ⩓ True = x
False ⩓ False = False

(⩔) ∷ 𝔹 → 𝔹 → 𝔹
False ⩔ x = x
x ⩔ False = x
True ⩔ True = True

cond ∷ 𝔹 → a → a → a
cond b x y = case b of {True → x;False → y}

-- Lists --

stream𝐿 ∷ 𝐿 a → 𝑆 a
stream𝐿 xs₀ = 𝑆 xs₀ g
  where
    g Nil = None
    g (x :& xs) = Some (x :* xs)

list𝐼 ∷ 𝐼 a → 𝐿 a
list𝐼 = foldr𝐼 Nil (:&)

-- LazyLists --
 
streamLL ∷ [a] → 𝑆 a
streamLL xs₀ = 𝑆 xs₀ g
  where
    g [] = None
    g (x:xs) = Some (x :* xs)

lazyList𝐼 ∷ 𝐼 a → [a]
lazyList𝐼 = foldr𝐼 [] (:)

-- Iterators --

fold𝐼 ∷ b → (a → b → b) → 𝐼 a → b
fold𝐼 i f (𝐼 g) = g f i

foldk𝐼 ∷ b → (a → (b → b) → b → b) → 𝐼 a → b
foldk𝐼 i f (𝐼 g) = g f id i

foldr𝐼 ∷ b → (a → b → b) → 𝐼 a → b
foldr𝐼 i f = foldk𝐼 i $ \ x k → k ∘ f x

map𝐼 ∷ (a → b) → 𝐼 a → 𝐼 b
map𝐼 f (𝐼 g) = 𝐼 $ \ f' → g $ f' ∘ f

-- Streams --

iter𝑆 ∷ 𝑆 a → 𝐼 a
iter𝑆 (𝑆 s₀ g) = 𝐼 $ \ f i₀ →
  let loop i s = case g s of
        None → i
        Some (x :* s') → loop (f x i) s'
  in loop i₀ s₀

-- Compat --

class CHS a b | b → a where 
  tohs ∷ a → b
  frhs ∷ b → a

instance {-# OVERLAPPABLE #-} (a ~ b) ⇒ CHS a b where {tohs = id;frhs = id}
instance {-# OVERLAPPING #-} CHS ℤ32 HS.Int where
  tohs = HS.fromIntegral
  frhs = HS.fromIntegral
instance {-# OVERLAPPING #-} (CHS a b) ⇒ CHS (𝐿 a) [b] where 
  tohs = lazyList𝐼 ∘ map𝐼 tohs ∘ iter𝑆 ∘ stream𝐿
  frhs = list𝐼 ∘ map𝐼 frhs ∘ iter𝑆 ∘ streamLL
instance {-# OVERLAPPING #-} (CHS a₁ b₁,CHS a₂ b₂,CHS a₃ b₃) ⇒ CHS (a₁ ∧ a₂ ∧ a₃) (b₁,b₂,b₃) where
  tohs (x :* y :* z) = (tohs x,tohs y,tohs z)
  frhs (x,y,z) = frhs x :* frhs y :* frhs z
instance {-# OVERLAPPING #-} (CHS a₁ b₁,CHS a₂ b₂) ⇒ CHS (a₁ ∧ a₂) (b₁,b₂) where
  tohs (x :* y) = (tohs x,tohs y)
  frhs (x,y) = frhs x :* frhs y
instance {-# OVERLAPPING #-} (CHS a₁ b₁,CHS a₂ b₂) ⇒ CHS (a₁ ∨ a₂) (HS.Either b₁ b₂) where
  tohs = \case
    Inl x → HS.Left $ tohs x
    Inr y → HS.Right $ tohs y
  frhs = \case
    HS.Left x → Inl $ frhs x 
    HS.Right y → Inr $ frhs y
instance {-# OVERLAPPING #-} (CHS a b) ⇒ CHS (𝑂 a) (HS.Maybe b) where
  tohs = \case
    None → HS.Nothing
    Some x → HS.Just $ tohs x
  frhs = \case
    HS.Nothing → None
    HS.Just x → Some $ frhs x