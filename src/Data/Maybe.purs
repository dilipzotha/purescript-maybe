module Data.Maybe where

import Control.Alt
import Control.Alternative
import Control.Extend
import Control.MonadPlus
import Control.Plus

-- | The `Maybe` type is used to represent optional values and can be seen as
-- | something like a type-safe `null`, where `Nothing` is `null` and `Just x`
-- | is the non-null value `x`.
data Maybe a = Nothing | Just a

-- | Takes a default value, a function, and a `Maybe` value. If the `Maybe`
-- | value is `Nothing` the default value is returned, otherwise the function
-- | is applied to the value inside the `Just` and the result is returned.
-- |
-- | ``` purescript
-- | maybe default f Nothing == default
-- | maybe default f (Just x) == f x
-- | ```
maybe :: forall a b. b -> (a -> b) -> Maybe a -> b
maybe b _ Nothing = b
maybe _ f (Just a) = f a

-- | Takes a default value, and a `Maybe` value. If the `Maybe` value is
-- | `Nothing` the default value is returned, otherwise the value inside the
-- | `Just` is returned.
-- |
-- | ``` purescript
-- | fromMaybe default Nothing == default
-- | fromMaybe default (Just x) == x
-- | ```
fromMaybe :: forall a. a -> Maybe a -> a
fromMaybe a = maybe a (id :: forall a. a -> a)

-- | Returns `true` when the `Maybe` value was constructed with `Just`.
isJust :: forall a. Maybe a -> Boolean
isJust = maybe false (const true)

-- | Returns `true` when the `Maybe` value is `Nothing`.
isNothing :: forall a. Maybe a -> Boolean
isNothing = maybe true (const false)

-- | The `Functor` instance for `Maybe` allows functions to transform the
-- | contents of a `Just` with the `<$>` operator:
-- |
-- | ``` purescript
-- | Just x <$> f == Just (f x)
-- | ```
-- |
-- | `Nothing` values are left untouched:
-- |
-- | ``` purescript
-- | Nothing <$> f == Nothing
-- | ```
instance functorMaybe :: Functor Maybe where
  (<$>) fn (Just x) = Just (fn x)
  (<$>) _  _        = Nothing

-- | The `Apply` instance for `Maybe` allows functions contained within a `Just`
-- | to transform a value contained within a `Just` using the `(<*>)` operator:
-- |
-- | ``` purescript
-- | Just f <*> Just x == Just (f x)
-- | ```
-- |
-- | `Nothing` values are left untouched:
-- |
-- | ``` purescript
-- | Just f <$> Nothing == Nothing
-- | Nothing <$> Just x == Nothing
-- | ```
-- |
-- | Combining `Functor`'s' `<$>` with `Apply`'s `<*>` can be used to pass
-- | multiple `Maybe` values to a function that does not usually expect them:
-- |
-- | ``` purescript
-- | f <$> Just x <*> Just y == Just (f x y)
-- | ```
-- |
-- | The `Nothing`-preserving behaviour of both operators means the result of
-- | an expression like the above but where any one of the values is `Nothing`
-- | means the whole result becomes `Nothing` also:
-- |
-- | ``` purescript
-- | f <$> Nothing <*> Just y == Nothing
-- | f <$> Just x <*> Nothing == Nothing
-- | f <$> Nothing <*> Nothing == Nothing
-- | ```
instance applyMaybe :: Apply Maybe where
  (<*>) (Just fn) x = fn <$> x
  (<*>) Nothing   _ = Nothing

-- | The `Applicative` instance for `Maybe` enables lifting of values into
-- | `Maybe` with the `pure` function:
-- |
-- | ``` purescript
-- | pure x :: Maybe _ == Just x
-- | ```
-- |
-- | Combining `Functor`'s' `<$>` with `Apply`'s `<*>` and `Applicative`'s
-- | `pure` can be used to pass a mixture of `Maybe` and non-`Maybe` typed
-- | values to a function that does not usually expect them, by using `pure`
-- | for any value that is not already `Maybe` typed:
-- |
-- | ``` purescript
-- | f <$> Just x <*> pure y == Just (f x y)
-- | ```
-- |
-- | Even though `pure = Just` it is recommended to use `pure` in situations
-- | like this as it allows the choice of `Applicative` to be changed later
-- | without having to go through and replace `Just` with a new constructor.
instance applicativeMaybe :: Applicative Maybe where
  pure = Just

-- | The `Alt` instance for `Maybe` allows for a choice to be made between two
-- | `Maybe` values with the `<|>` operator, where the first `Just` encountered
-- | is taken.
-- |
-- | ``` purescript
-- | Just x <|> Just y == Just x
-- | Nothing <|> Just y == Just y
-- | Nothing <|> Nothing == Nothing
-- | ```
instance altMaybe :: Alt Maybe where
  (<|>) Nothing r = r
  (<|>) l       _ = l

-- | The `Plus` instance for `Maybe` enables a `Maybe` value to be constructed
-- | from no other values with the `empty` function:
-- |
-- | ``` purescript
-- | empty :: Maybe _ == Nothing
-- | ```
instance plusMaybe :: Plus Maybe where
  empty = Nothing

-- | The `Alternative` instance for `Maybe` guarantees that there are both
-- | `Applicative` and `Plus` instances for `Maybe`.
instance alternativeMaybe :: Alternative Maybe

-- | The `Bind` instance for `Maybe` allows sequencing of `Maybe` values and
-- | functions that return a `Maybe` by using the `>>=` operator:
-- |
-- | ``` purescript
-- | Just x >>= f = f x
-- | Nothing >>= f = Nothing
-- | ```
instance bindMaybe :: Bind Maybe where
  (>>=) (Just x) k = k x
  (>>=) Nothing  _ = Nothing

instance monadMaybe :: Monad Maybe

instance monadPlusMaybe :: MonadPlus Maybe

-- | ``` purescript
-- | f <<= Nothing = Nothing
-- | f <<= Just x = Just (f x)
-- | ```
instance extendMaybe :: Extend Maybe where
  (<<=) _ Nothing  = Nothing
  (<<=) f x        = Just (f x)

-- | ``` purescript
-- | Just x <> Just y = Just (x <> y)
-- | Just x <> Nothing = Just x
-- | Nothing <> Just y = Just y
-- | Nothing <> Nothing = Nothing
-- | ```
instance semigroupMaybe :: (Semigroup a) => Semigroup (Maybe a) where
  (<>) Nothing  x        = x
  (<>) x        Nothing  = x
  (<>) (Just x) (Just y) = Just (x <> y)

instance showMaybe :: (Show a) => Show (Maybe a) where
  show (Just x) = "Just (" ++ show x ++ ")"
  show Nothing  = "Nothing"

-- | The `Eq` instance allows `Maybe` values to be checked for equality with
-- | `==` and inequality with `/=` whenever there is an `Eq` instance for the
-- | type the `Maybe` contains.
instance eqMaybe :: (Eq a) => Eq (Maybe a) where
  (==) Nothing   Nothing   = true
  (==) (Just a1) (Just a2) = a1 == a2
  (==) _         _         = false
  (/=) a b = not (a == b)

-- | The `Ord` instance allows `Maybe` values to be compared with
-- | `compare`, `>`, `>=`, `<` and `<=` whenever there is an `Ord` instance for
-- | the type the `Maybe` contains.
-- |
-- | `Nothing` is considered to be less than any `Just` value.
instance ordMaybe :: (Ord a) => Ord (Maybe a) where
  compare (Just x) (Just y) = compare x y
  compare Nothing  Nothing  = EQ
  compare Nothing  _        = LT
  compare _        Nothing  = GT
