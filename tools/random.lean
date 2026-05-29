-- mccole: random
-- Read n bytes of OS entropy and combine them into a single Nat
def randomBytes (n : USize) : IO Nat := do
  let bytes ← IO.getRandomBytes n
  return bytes.toList.foldl (fun acc b => acc * 256 + b.toNat) 0

-- Return a Nat sampled uniformly from [lo, hi] (both inclusive)
def randomInRange (lo hi : Nat) : IO Nat := do
  let raw ← randomBytes 4  -- 4 bytes = 32 bits of entropy
  return lo + raw % (hi - lo + 1)
-- mccole: /random

-- mccole: tests
-- Pure helper exposed for testing: maps a raw value to the range [lo, hi]
def mapToRange (lo hi raw : Nat) : Nat := lo + raw % (hi - lo + 1)

-- raw = 0 always maps to lo
#guard mapToRange 1 6 0 == 1
-- raw = hi - lo always maps to hi (the top is reachable)
#guard mapToRange 0 5 5 == 5
-- result is always at most hi
#guard mapToRange 0 9 999 ≤ 9
-- result is always at least lo
#guard mapToRange 3 7 0 ≥ 3
-- mccole: /tests

-- mccole: main
def main : IO Unit := do
  let roll ← randomInRange 1 6
  IO.println s!"dice roll: {roll}"
  let pick ← randomInRange 0 2
  IO.println s!"random colour: {(["red", "green", "blue"])[pick]!}"
  -- sample a few values to show the range
  let samples ← List.range 5 |>.mapM (fun _ => randomInRange 10 99)
  IO.println s!"five samples in [10, 99]: {samples}"
-- mccole: /main
