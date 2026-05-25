-- Use conditionals inside match branches when constructors aren't enough
def describe (n : Int) : String :=
  match n with
  | n' =>
    if n' > 0 then "positive"
    else if n' < 0 then "negative"
    else "zero"

#eval describe 5
#eval describe (-3)
#eval describe 0
