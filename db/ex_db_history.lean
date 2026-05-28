-- Write a function that returns the full history of values for a key
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbHistory (log : Log) (key : String) : List (Option String) :=
  []

#guard dbHistory [("x", some "1"), ("x", none), ("x", some "2")] "x"
        == [some "1", none, some "2"]
#guard dbHistory [("y", some "1")] "x" == []