-- mccole: tc-two-classes
-- Two independent type classes
class Describable (α : Type) where
  describe : α → String

class Weighable (α : Type) where
  weight : α → Nat
-- mccole: /tc-two-classes

-- mccole: tc-fruit
inductive Fruit where | Apple | Banana | Cherry
  deriving Repr

instance : Describable Fruit where
  describe
    | Fruit.Apple  => "apple"
    | Fruit.Banana => "banana"
    | Fruit.Cherry => "cherry"

instance : Weighable Fruit where
  weight
    | Fruit.Apple  => 180
    | Fruit.Banana => 120
    | Fruit.Cherry => 5
-- mccole: /tc-fruit

-- mccole: tc-two-constraints
-- A function can require multiple type class constraints
def report [Describable α] [Weighable α] (x : α) : String :=
  s!"{Describable.describe x} weighs {Weighable.weight x}g"
-- mccole: /tc-two-constraints

-- mccole: tc-multi-use
#eval report Fruit.Apple
#eval report Fruit.Banana
#eval report Fruit.Cherry
-- mccole: /tc-multi-use
