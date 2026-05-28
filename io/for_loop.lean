-- Iterate over a list in a do block with for
def main : IO Unit := do
  let fruits := ["apple", "banana", "cherry"]
  for fruit in fruits do
    IO.println fruit

#eval main
