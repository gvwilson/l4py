-- Write a Doubleable type class with a `twice` method that returns
-- the doubled value. Then write an instance for Nat.

class Doubleable (α : Type) where
  twice : α → α

-- TODO: write an instance for Nat

#guard Doubleable.twice (0 : Nat) == 0
#guard Doubleable.twice (21 : Nat) == 42
#guard Doubleable.twice (100 : Nat) == 200
