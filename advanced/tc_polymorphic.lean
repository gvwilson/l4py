class Describable (α : Type) where
  describe : α → String

instance : Describable Bool where
  describe b := if b then "yes" else "no"

instance : Describable Int where
  describe n := s!"the number {n}"

instance : Describable String where
  describe s := s!"'{s}'"

-- mccole: tc-poly
-- [Describable α] is a constraint: α must have a Describable instance
def showAll [Describable α] (xs : List α) : String :=
  String.intercalate ", " (xs.map Describable.describe)
-- mccole: /tc-poly

-- mccole: tc-poly-use
#eval showAll [true, false, true]
#eval showAll [(1 : Int), 2, 3]
#eval showAll ["hello", "world"]
-- mccole: /tc-poly-use
