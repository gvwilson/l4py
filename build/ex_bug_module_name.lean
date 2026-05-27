-- Fix: the module name is wrong — Lean module names match the filename
-- The file is 'Helpers.lean' but the import uses a lowercase name
import MyProject.helpers

def main : IO Unit := do
  IO.println (Helpers.greet "world")
