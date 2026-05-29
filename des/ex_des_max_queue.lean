-- Write a function that computes the maximum queue size during a simulation.
-- You'll need to track the peak. For this simplified version, return the
-- final queue size as a starting point and improve from there.

structure SimState where
  time         : Float
  queueSize    : Nat
  totalProduced : Nat
  totalConsumed : Nat

-- Return the highest queue size ever observed.
-- Since this simplified SimState only tracks the current queue, use
-- max of what's currently in the queue vs. what was produced but not consumed.
def maxQueueSize (s : SimState) : Nat :=
  0

#guard
  let s : SimState := { time := 10.0, queueSize := 5,
                         totalProduced := 20, totalConsumed := 15 }
  maxQueueSize s >= s.queueSize

#guard
  let s : SimState := { time := 0.0, queueSize := 0,
                         totalProduced := 0, totalConsumed := 0 }
  maxQueueSize s == 0

#guard
  let s : SimState := { time := 5.0, queueSize := 0,
                         totalProduced := 5, totalConsumed := 5 }
  maxQueueSize s == 0
