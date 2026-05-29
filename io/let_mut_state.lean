-- let mut looks like mutation but compiles to state-passing under the hood
-- The compiler rewrites mutable variables into function arguments
def countEvens (xs : List Int) : IO Nat := do
  let mut count := 0
  for x in xs do
    if x % 2 == 0 then
      count := count + 1
  return count

-- The same logic as a pure function using foldl (no IO, no mutation)
def countEvensPure (xs : List Int) : Nat :=
  xs.foldl (fun acc x => if x % 2 == 0 then acc + 1 else acc) 0

#eval countEvens [1, 2, 3, 4, 5, 6]
#eval countEvensPure [1, 2, 3, 4, 5, 6]
