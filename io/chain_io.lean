-- Chain multiple ← binds in a single do block
def main : IO Unit := do
  IO.println "Enter your first name:"
  let stdin ← IO.getStdin
  let first ← stdin.getLine
  IO.println "Enter your last name:"
  let last ← stdin.getLine
  IO.println s!"Hello, {first.trimAscii} {last.trimAscii}!"

#eval main
