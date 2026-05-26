-- Should print the doubled value, but has a bug. Fix it.
def double (n : Int) : Int := n * 2

def main : IO Unit := do
  let result ← double 5
  IO.println s!"Result: {result}"

#eval main
