-- This keeps the oldest value instead of the newest. Fix it.
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry

def dbCompact (log : Log) : Log :=
  let (_, kept) := log.foldl (init := ([], [])) fun (seen, acc) (k, v) =>
    if seen.contains k then (seen, acc)
    else (k :: seen, (k, v) :: acc)
  kept

#guard dbCompact [("a", some "1"), ("b", some "1"), ("a", some "2"), ("b", none)]
        == [("a", some "2"), ("b", none)]