-- `let x := expr` binds a pure value inside a do block
def greet (name : String) : String :=
  s!"Hello, {name}!"

def main : IO Unit := do
  let msg := greet "Lean"
  IO.println msg

#eval main
