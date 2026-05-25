-- This function should return the product of all numbers in a list
-- but it always returns 0. Fix the bug.
def product (xs : List Int) : Int :=
  match xs with
  | [] => 0
  | x :: rest => x * product rest
