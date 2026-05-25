-- Option is defined in the standard library as:
-- inductive Option (α : Type) where
--   | none : Option α
--   | some (val : α) : Option α

-- So you can pattern match on it like any other sum type
def describeOpt (x : Option Int) : String :=
  match x with
  | Option.none => "nothing"
  | Option.some n => s!"got {n}"

#eval describeOpt (Option.some 42)
#eval describeOpt Option.none
