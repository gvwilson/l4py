-- mccole: tc-class
-- Define a type class with one required method
class Describable (α : Type) where
  describe : α → String
-- mccole: /tc-class

-- mccole: tc-bool
-- An instance teaches Lean how to describe a specific type
instance : Describable Bool where
  describe b := if b then "yes" else "no"
-- mccole: /tc-bool

-- mccole: tc-int
instance : Describable Int where
  describe n := s!"the number {n}"
-- mccole: /tc-int

-- mccole: tc-use
#eval Describable.describe true
#eval Describable.describe (42 : Int)
-- mccole: /tc-use
