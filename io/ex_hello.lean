-- Add a second line so main prints "Hello, Lean!" then "Ready to go!"
def main : IO Unit := do
  IO.println "Hello, Lean!"

#eval main
