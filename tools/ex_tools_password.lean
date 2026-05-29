-- Write a pure function that generates a random-looking password of a
-- given length by picking characters from an alphabet using an index.
-- Use a simple seed-based approach (no IO needed for this exercise).

-- Pick the character at the given index from the alphabet, wrapping around.
def pickChar (alphabet : String) (index : Nat) : Char :=
  alphabet.toList[index % alphabet.length]!

-- Generate a password by using the seed to pick one character at a time.
-- Advance the seed with each pick using a simple LCG.
def generatePassword (length : Nat) (seed : Nat) : String × Nat :=
  let alphabet := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  ("", seed)  -- TODO

#guard
  let (pw, _) := generatePassword 8 12345
  pw.length == 8

#guard
  let (pw1, _) := generatePassword 8 42
  let (pw2, _) := generatePassword 8 99
  pw1 != pw2  -- different seeds produce different passwords

#guard
  let (pw, _) := generatePassword 0 1
  pw == ""
