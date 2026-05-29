-- The Describable instance for Nat has the wrong method signature.
-- describe should return String, but this one returns Nat. Fix it.
class Describable (α : Type) where
  describe : α → String

-- BUG: describe returns Nat instead of String
instance : Describable Nat where
  describe n := n

#guard Describable.describe (0 : Nat) == "0"
#guard Describable.describe (42 : Nat) == "42"
