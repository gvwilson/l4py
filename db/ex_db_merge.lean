-- Write a function that merges two logs (second log's entries are newer)
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbMerge (log1 log2 : Log) : Log :=
  []

#guard dbMerge [("x", some "1")] [("x", some "2")] == [("x", some "1"), ("x", some "2")]
#guard dbMerge [] [("a", some "1")] == [("a", some "1")]