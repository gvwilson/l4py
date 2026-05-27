-- Fix: the intermediate step asserts the wrong value
theorem sumTwo : 10 + 20 = 30 := by
  have h : 10 + 20 = 31 := by rfl
  omega
