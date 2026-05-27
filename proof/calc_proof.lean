theorem sixViaTwo : 2 + 4 = 6 := by
  calc 2 + 4 = 4 + 2 := by omega
    _ = 6   := by rfl

theorem boundsCheck (n : Nat) (h : n ≤ 5) : n + n ≤ 10 := by
  calc n + n = 2 * n := by omega
    _ ≤ 2 * 5 := by omega
    _ = 10    := by rfl
