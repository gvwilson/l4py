-- This function should return a greeting, but has a bug. Fix it.
def getGreeting : IO String := do
  let msg := "Hello!"
  msg

def main : IO Unit := do
  let g ← getGreeting
  IO.println g

#eval main
