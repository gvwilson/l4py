-- This function should print a message, but its return type is wrong. Fix it.
def announce (item : String) : IO String := do
  IO.println s!"Announcing: {item}"

def main : IO Unit := do
  announce "Lean 4"

#eval main
