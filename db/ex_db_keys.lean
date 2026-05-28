-- Write a function that returns all unique keys in the log (deduplicated)
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def keys (log : Log) : List String :=
  []

#guard keys [("a", some "1"), ("b", some "2"), ("a", some "3")] == ["a", "b"]
#guard keys [] == []