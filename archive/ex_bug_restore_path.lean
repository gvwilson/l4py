-- restore constructs the blob path wrong: it uses the file path instead
-- of the hash to read the blob. Fix the file path construction.
abbrev Hash := String
abbrev Manifest := List (String × Hash)

def restore (manifest : Manifest) (archiveDir : String) : IO Unit := do
  for (path, _h) in manifest do
    let bytes ← IO.FS.readBinFile s!"{archiveDir}/{path}.bck"
    IO.FS.writeBinFile path bytes

-- To test: first run snapshot on sample data, then restore with this.
-- The bug path uses the file name instead of the hash for the blob file.