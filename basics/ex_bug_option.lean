-- This function should extract a value from an Option
-- or return "missing" for Option.none. Fix the bug.
def getValue (opt : Option String) : String :=
  match opt with
  | Option.some s => s
