theorem zeroAdd (n : Nat) : 0 + n = n := by
  induction n with
  | zero    => rfl
  | succ n ih => omega
#check @zeroAdd
