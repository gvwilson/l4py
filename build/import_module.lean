-- Main.lean: imports and uses the Helpers module
import MyProject.Helpers

def main : IO Unit := do
  IO.println (Helpers.greet "Lake")
  IO.println (Helpers.shout "lean")
