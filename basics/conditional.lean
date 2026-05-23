def classify (n : Int) : String :=
  if n > 0 then "positive"
  else if n < 0 then "negative"
  else "zero"

#eval classify 5
#eval classify (-3)
#eval classify 0
