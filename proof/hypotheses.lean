theorem positiveSum (a b : Int) (ha : 0 < a) (hb : 0 < b) : 0 < a + b := by omega
theorem bounded (n : Nat) (h : n < 10) : n ≤ 9 := by omega
#check @positiveSum
