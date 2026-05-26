-- imperative style: accumulate in mutable variables
-- (Python equivalent shown in comment)

-- Lean version with explicit recursion:
def sumOfSquaresOfEvens (xs : List Int) : Int :=
  match xs with
  | [] => 0
  | x :: rest =>
    let restResult := sumOfSquaresOfEvens rest
    if x % 2 == 0 then x*x + restResult else restResult

#eval sumOfSquaresOfEvens [1, 2, 3, 4]

-- pipeline style: describe what you want, not how
#eval [1, 2, 3, 4]
  |> List.filter (· % 2 == 0)
  |> List.map (· ^ 2)
  |> List.foldl (· + ·) 0
