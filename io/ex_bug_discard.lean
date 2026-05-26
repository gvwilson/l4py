-- Should print both lines, but only prints one. Fix it.
def main : IO Unit := do
  IO.println "Step 1: start"
  let _ := IO.println "Step 2: done"

#eval main
