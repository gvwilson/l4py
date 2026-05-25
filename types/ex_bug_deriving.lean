-- Comparing Color values should work, but the code won't compile.
-- Fix it by adding a `deriving` clause.
inductive Color where
  | red | green | blue

def isRed (c : Color) : Bool :=
  c == Color.red
