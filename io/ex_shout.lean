-- Fix printLoud so it prints the message in uppercase.
-- Hint: String.toUpper converts a String to all caps.
def printLoud (msg : String) : IO Unit :=
  IO.println msg

def main : IO Unit := do
  printLoud "hello"
  printLoud "world"

#eval main
