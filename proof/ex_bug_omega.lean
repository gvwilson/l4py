-- Fix: this theorem is false; omega correctly rejects it
theorem claim (n : Nat) : n + 1 < n := by omega
