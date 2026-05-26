-- Pure functions have no side effects and can be called from do blocks
def square (n : Int) : Int := n * n

def main : IO Unit := do
  let result := square 7
  IO.println s!"7 squared is {result}"
  IO.println s!"12 squared is {square 12}"

#eval main
