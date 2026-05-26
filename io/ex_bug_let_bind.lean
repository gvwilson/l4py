-- Should print the greeting, but has a bug. Fix it.
def makeMsg : IO String := return "Hello, Lean!"

def main : IO Unit := do
  let msg := makeMsg
  IO.println msg

#eval main
