-- This function should describe a StringOrInt, but the match
-- is missing a case. Fix it.
inductive StringOrInt where
  | str : String → StringOrInt
  | num : Int → StringOrInt

def describe (x : StringOrInt) : String :=
  match x with
  | StringOrInt.str s => s!"string: \"{s}\""
