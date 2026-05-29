-- Write a function that computes the utilization of the queue:
-- the fraction of capacity that's in use. Return 0.0 for zero capacity.

structure SimState where
  queueSize    : Nat
  totalProduced : Nat
  totalConsumed : Nat

-- Utilization is the ratio of current queue size to capacity.
-- Return 0.0 when capacity is 0 to avoid division by zero.
def utilization (s : SimState) (capacity : Nat) : Float :=
  0.0

#guard
  let s : SimState := { queueSize := 3, totalProduced := 10, totalConsumed := 7 }
  utilization s 5 == 0.6

#guard
  let s : SimState := { queueSize := 0, totalProduced := 0, totalConsumed := 0 }
  utilization s 5 == 0.0

#guard
  let s : SimState := { queueSize := 4, totalProduced := 4, totalConsumed := 0 }
  utilization s 0 == 0.0
