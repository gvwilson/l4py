-- Functions can return IO actions, not just plain values
def printTwice (msg : String) : IO Unit := do
  IO.println msg
  IO.println msg

def main : IO Unit := do
  printTwice "echo!"
  printTwice "again"

#eval main
