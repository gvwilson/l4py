-- This function should return a String, but the let binding produces
-- an Int without converting it. Fix the type mismatch.
def describeValue (x : Int) : String :=
  let doubled := x * 2
  doubled

#guard describeValue 5 == "10"