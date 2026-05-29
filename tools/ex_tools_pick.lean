-- Write a pure function that picks one element from a non-empty list by index
-- pick xs i returns xs[i % xs.length] so any Nat index is valid

def pick (xs : List String) (i : Nat) : Option String :=
  none  -- TODO

#guard pick ["a", "b", "c"] 0 == some "a"
#guard pick ["a", "b", "c"] 2 == some "c"
-- index wraps around: 3 % 3 == 0
#guard pick ["a", "b", "c"] 3 == some "a"
-- empty list returns none
#guard (pick [] 0).isNone
