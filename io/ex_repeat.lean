-- Fix repeat3 so it calls IO.println with msg exactly three times.
def repeat3 (msg : String) : IO Unit := do
  IO.println msg

def main : IO Unit := do
  repeat3 "again"

#eval main
