-- This should print two lines but has a bug. Fix it.
def main : IO Unit :=
  IO.println "Hello"
  IO.println "World"

#eval main
