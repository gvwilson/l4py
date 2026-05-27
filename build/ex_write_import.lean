-- Write: add the missing import and fix the main function
-- Assume MyProject.Greeter defines Greeter.greet

def main : IO Unit := do
  IO.println (Greeter.greet "World")
