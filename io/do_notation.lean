-- Use `do` to run IO actions one after another
def main : IO Unit := do
  IO.println "Step 1: start"
  IO.println "Step 2: middle"
  IO.println "Step 3: done"

#eval main
