-- Structural recursion: Lean proves termination automatically
-- because the list argument shrinks with each recursive call
def mySum : List Nat → Nat
  | []      => 0
  | x :: xs => x + mySum xs

#eval mySum [1, 2, 3, 4, 5]

-- termination_by: tell Lean which expression decreases each call
-- Use this when the termination measure is not the argument itself
-- decreasing_by provides a tactic to discharge the proof obligation
def repeatStr (s : String) : Nat → String
  | 0     => ""
  | n + 1 => s ++ repeatStr s n

#eval repeatStr "ab" 3

-- partial: opt out of termination checking entirely
-- Use only when you are certain the function terminates
-- and cannot express the measure with termination_by
partial def findFirst (p : α → Bool) : List α → Option α
  | []      => none
  | x :: xs => if p x then some x else findFirst p xs

#eval findFirst (· > 3) [1, 2, 3, 4, 5]
