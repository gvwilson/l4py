-- trying to derive Repr on a type that uses a field without a Repr instance.
-- Repr can't be derived automatically here. Fix the error.
inductive Toy where
  | car
  | doll
  deriving Repr

-- BUG: MyBox can't derive Repr because Toy doesn't derive Repr
-- The error chain is: MyBox → needs Repr → Toy doesn't have it → fail
structure MyBox where
  toy : Toy
  label : String
  deriving Repr

#guard ({ toy := Toy.car, label := "red" : MyBox }).label == "red"
