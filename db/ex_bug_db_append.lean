-- Missing do block: two IO actions need sequencing
def appendEntry (path key : String) (val : Option String) : IO Unit :=
  let h ← IO.FS.Handle.mk path IO.FS.Mode.append
  h.putStr s!"{key}\t{val.getD ""}\n"
  h.flush

#eval appendEntry "db/test.log" "hello" (some "world")