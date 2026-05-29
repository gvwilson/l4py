-- report requires both Describable and Weighable constraints, but the
-- function signature only lists Describable. Add the missing constraint.
class Describable (α : Type) where
  describe : α → String

class Weighable (α : Type) where
  weight : α → Nat

inductive Fruit where | Apple | Banana
  deriving Repr

instance : Describable Fruit where
  describe | .Apple => "apple" | .Banana => "banana"

instance : Weighable Fruit where
  weight | .Apple => 180 | .Banana => 120

-- BUG: [Weighable α] constraint is missing
def report [Describable α] (x : α) : String :=
  s!"{Describable.describe x} weighs {Weighable.weight x}g"

#guard report Fruit.Apple == "apple weighs 180g"
#guard report Fruit.Banana == "banana weighs 120g"
