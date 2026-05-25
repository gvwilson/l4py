-- A generic sum type for success or failure
inductive Result (α : Type) (β : Type) where
  | ok (val : α)
  | err (msg : β)
deriving Repr

def divide (a : Int) (b : Int) : Result Int String :=
  if b == 0 then
    Result.err "division by zero"
  else
    Result.ok (a / b)

#eval divide 10 2
#eval divide 10 0
