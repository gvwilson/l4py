-- This function should return the first element of a list
-- or 0 if the list is empty. Fix the bug.
def firstOrZero (xs : List Int) : Int :=
  match xs with
  | x :: _ => x
