theorem nilAppend : ([] : List Nat) ++ [1, 2] = [1, 2] := by simp
theorem appendNil (xs : List Nat) : xs ++ [] = xs := by simp
theorem listLen : [1, 2, 3].length = 3 := by simp
