-- Fix: this file uses Utils.greet but forgets to import it
-- Add the missing import at the top

def main : IO Unit := do
  IO.println (Utils.greet "world")
