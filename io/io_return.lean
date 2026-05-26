-- Use ← to capture the result of an IO action
def makeGreeting : IO String := do
  IO.println "Building greeting..."
  return "Hello from IO!"

def main : IO Unit := do
  let msg ← makeGreeting
  IO.println msg

#eval main
