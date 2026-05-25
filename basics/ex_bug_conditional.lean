-- This function should return "positive", "negative", or "zero"
-- but it has a bug. Fix it.
def describe (n : Int) : String :=
  if n > 0 then
    "positive"
  else if n < 0 then
    "negative"
