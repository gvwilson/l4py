-- Write a function that counts how many times a key appears in the log
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def countEntries (log : Log) (key : String) : Nat :=
  0

#guard countEntries [("x", some "1"), ("x", some "2"), ("y", some "1")] "x" == 2
#guard countEntries [("x", none), ("x", some "1")] "x" == 2
#guard countEntries [] "x" == 0