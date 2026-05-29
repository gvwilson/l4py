-- Write a function `describeWeight` that has BOTH Describable and Weighable
-- constraints and returns a string like "an apple weighs 180g".

class Describable (α : Type) where
  describe : α → String

class Weighable (α : Type) where
  weight : α → Nat

inductive Fruit where | Apple | Banana
  deriving Repr

instance : Describable Fruit where
  describe | .Apple => "an apple" | .Banana => "a banana"

instance : Weighable Fruit where
  weight | .Apple => 180 | .Banana => 120

-- TODO: write describeWeight with both constraints
def describeWeight (x : Fruit) : String :=
  ""

#guard describeWeight Fruit.Apple == "an apple weighs 180g"
#guard describeWeight Fruit.Banana == "a banana weighs 120g"
