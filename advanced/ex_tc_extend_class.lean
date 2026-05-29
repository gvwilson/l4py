-- Extend the Measurable class with a Comparable class that adds
-- a `biggerThan` method. Write an instance for Nat.

class Measurable (α : Type) where
  size : α → Nat

class Comparable (α : Type) extends Measurable α where
  biggerThan : α → α → Bool

-- TODO: write an instance of Comparable for Nat

#guard Measurable.size (42 : Nat) == 42
#guard Comparable.biggerThan (10 : Nat) (5 : Nat) == true
#guard Comparable.biggerThan (3 : Nat) (7 : Nat) == false
