-- Accumulate a result across loop iterations using let mut
def main : IO Unit := do
  let words := ["hello", "world", "from", "Lean"]
  let mut count := 0
  for w in words do
    if w.length > 4 then
      count := count + 1
  IO.println s!"Words longer than 4 chars: {count}"

#eval main
