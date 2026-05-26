-- Fix main so it computes and prints the sum of the list (should be 15).
def addUp (xs : List Int) : Int := xs.foldl (· + ·) 0

def main : IO Unit := do
  IO.println "Sum is 0"

#eval main
