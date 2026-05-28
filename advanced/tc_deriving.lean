-- mccole: tc-deriving-what
-- Repr and BEq are type classes just like any user-defined class
-- deriving Repr generates an instance of the Repr class automatically
inductive Color where
  | Red | Green | Blue
  deriving Repr, BEq
-- mccole: /tc-deriving-what

-- mccole: tc-deriving-manual
-- Some classes cannot be derived — you write the instance by hand
class Describable (α : Type) where
  describe : α → String

instance : Describable Color where
  describe
    | Color.Red   => "red"
    | Color.Green => "green"
    | Color.Blue  => "blue"
-- mccole: /tc-deriving-manual

-- mccole: tc-deriving-use
-- Repr (from deriving) drives #eval output
#eval Color.Red
-- BEq (from deriving) enables ==
#guard Color.Red == Color.Red
#guard Color.Red != Color.Blue
-- Describable (written by hand) gives a custom string
#eval Describable.describe Color.Green
-- mccole: /tc-deriving-use
