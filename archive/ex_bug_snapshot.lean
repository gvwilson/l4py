-- snapshot should create the archive directory before writing blobs,
-- but it doesn't. The first file write will fail. Add the missing directory
-- creation step.
abbrev Hash := String

def snapshot (files : List (String × ByteArray)) (archiveDir : String) :
    IO Unit := do
  for (path, bytes) in files do
    let h : Hash := toString (hash bytes)
    IO.FS.writeBinFile s!"{archiveDir}/{h}.bck" bytes

#eval snapshot [("a.txt", "hello".toUTF8)] "test-archive"