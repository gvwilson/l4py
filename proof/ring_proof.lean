import Mathlib.Tactic

theorem mulComm (a b : Nat) : a * b = b * a := by ring
theorem distribLeft (a b c : Nat) : a * (b + c) = a * b + a * c := by ring
theorem squareSum (a b : Int) : (a + b) * (a + b) = a * a + 2 * a * b + b * b := by ring
#check @mulComm
