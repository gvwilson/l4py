-- Forgetting `do` is the most common IO mistake
def main : IO Unit :=
  IO.println "Starting..."
  IO.println "Done!"

#eval main
