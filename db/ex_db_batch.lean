-- Write a function that applies a batch of (key, value) updates to a log
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbSet (log : Log) (key val : String) : Log :=
  log ++ [(key, some val)]

def batchSet (log : Log) (updates : List (String × String)) : Log :=
  log

#guard batchSet [] [("x", "1"), ("y", "2")] == [("x", some "1"), ("y", some "2")]
#guard batchSet [("x", some "0")] [("x", "1")] == [("x", some "0"), ("x", some "1")]