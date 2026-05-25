-- This function should describe both success and failure,
-- but the match only handles the ok case. Fix it.
inductive Result (α : Type) (β : Type) where
  | ok (val : α)
  | err (msg : β)

def describe (r : Result Int String) : String :=
  match r with
  | Result.ok n => s!"success: {n}"
