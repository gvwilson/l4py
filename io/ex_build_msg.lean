-- Fix buildMsg so it returns "Message: " ++ text (using return).
def buildMsg (text : String) : IO String :=
  return text

def main : IO Unit := do
  let msg ← buildMsg "ready"
  IO.println msg

#eval main
