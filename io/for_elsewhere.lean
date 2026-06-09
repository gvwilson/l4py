-- for with let mut works in pure functions, not just IO do blocks
def countPositive (xs : List Int) : Nat :=
  let mut count := 0
  for x in xs do
    if x > 0 then count := count + 1
  count

#eval countPositive [-3, 1, -1, 4, 1, 5, -9, 2, -6]
