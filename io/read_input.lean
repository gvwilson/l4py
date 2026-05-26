-- IO.getStdin gives access to standard input
def main : IO Unit := do
  IO.println "Enter your name:"
  let stdin ← IO.getStdin
  let name ← stdin.getLine
  IO.println s!"Hello, {name.trimAscii}!"

#eval main
