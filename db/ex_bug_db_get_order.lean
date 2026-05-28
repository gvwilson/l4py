-- This scans front-to-back; should scan newest-first for latest-write-wins
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbGet (log : Log) (key : String) : Option String :=
  Option.join (log.findSome? (β := Option String) fun (k, v) =>
    if k == key then some v else none)

#guard dbGet [("x", some "1"), ("x", some "2")] "x" == some "2"
#guard dbGet [("x", none), ("x", some "1")] "x" == none