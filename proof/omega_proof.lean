theorem addComm (a b : Nat) : a + b = b + a := by omega
theorem gtZero (n : Nat) : 0 ≤ n := by omega
theorem noNegNat (n : Nat) : ¬(n < 0) := by omega
#check @addComm
