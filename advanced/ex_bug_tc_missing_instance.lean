-- Call showAll on a list of strings, but String has no Describable instance.
-- Add the missing instance so the guards pass.
class Describable (α : Type) where
  describe : α → String

instance : Describable Bool where
  describe b := if b then "yes" else "no"

instance : Describable Int where
  describe n := s!"the number {n}"

-- BUG: no instance for String, so showAll ["a", "b"] fails
def showAll [Describable α] (xs : List α) : String :=
  String.intercalate ", " (xs.map Describable.describe)

#guard showAll [true, false] == "yes, no"
#guard showAll [(1 : Int), 2] == "the number 1, the number 2"
#guard showAll ["a", "b"] == "a, b"
