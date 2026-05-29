-- mapToRange maps raw entropy to [lo, hi]; fix the modulus expression
-- BUG: divides by (hi - lo) instead of (hi - lo + 1), so hi is never reachable
def mapToRange (lo hi raw : Nat) : Nat :=
  lo + raw % (hi - lo)

-- when raw == hi - lo the result should be hi (the top of the range)
#guard mapToRange 0 5 5 == 5

-- the result should always be at most hi
#guard mapToRange 1 6 999 ≤ 6

-- the result should always be at least lo
#guard mapToRange 3 9 0 ≥ 3
