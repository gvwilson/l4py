-- Tombstones (none values) are not detected; Option.join is missing
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbGet (log : Log) (key : String) : Option String :=
  (List.reverse log).findSome? (β := Option String) fun (k, v) =>
    if k == key then some v else none

#guard dbGet [("x", none), ("x", some "1")] "x" == none