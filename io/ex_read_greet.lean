-- Fix main to read a name from stdin and print "Hello, <name>!"
-- instead of always printing "Hello, stranger!"
def main : IO Unit := do
  let stdin ← IO.getStdin
  let _name ← stdin.getLine
  IO.println "Hello, stranger!"

#eval main
