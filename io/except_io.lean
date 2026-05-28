-- try/catch wraps IO actions that might fail
def readFileSafe (path : String) : IO (Option String) := do
  try
    let content ← IO.FS.readFile path
    return some content
  catch _ =>
    return none

def main : IO Unit := do
  -- hello_world.lean exists in this directory
  match ← readFileSafe "hello_world.lean" with
  | some _ => IO.println "File found"
  | none   => IO.println "File not found"
  -- no_such_file.txt does not exist
  match ← readFileSafe "no_such_file.txt" with
  | some _ => IO.println "Unexpected success"
  | none   => IO.println "Missing file handled gracefully"

#eval main
