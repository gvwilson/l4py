theorem sumThree : 1 + 2 + 3 = 6 := by
  have h1 : 1 + 2 = 3 := by rfl
  have h2 : 3 + 3 = 6 := by rfl
  omega
