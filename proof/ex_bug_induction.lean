-- Fix: this claim is false; omega correctly rejects it
theorem alwaysGrows (n : Nat) : n + 1 > n + 1 := by omega
