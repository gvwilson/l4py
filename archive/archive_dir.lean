-- Core types and pure functions — identical to archive.lean
abbrev Hash := String
abbrev Manifest := List (String × Hash)

def hashBytes (ba : ByteArray) : Hash :=
  let h : UInt64 := hash ba
  let hex := "0123456789abcdef".toList
  let digits := (List.range 16).map fun i =>
    let nibble := (h >>> (60 - i * 4).toUInt64) &&& 0xF
    hex[nibble.toNat]!
  String.ofList digits

def buildManifest (files : List (String × ByteArray)) :
    Manifest × List (Hash × ByteArray) :=
  let entries := files.map fun (path, bytes) => (path, hashBytes bytes, bytes)
  let manifest := entries.map fun (path, h, _) => (path, h)
  let blobs := entries.foldl (init := []) fun acc (_, h, bytes) =>
    if acc.any (·.1 == h) then acc else acc ++ [(h, bytes)]
  (manifest, blobs)

def snapshot (files : List (String × ByteArray)) (archiveDir : String) :
    IO Manifest := do
  let (manifest, blobs) := buildManifest files
  for (h, bytes) in blobs do
    IO.FS.writeBinFile s!"{archiveDir}/{h}.bck" bytes
  return manifest

-- mccole: list-files
-- Collect all regular files in a directory as (path, bytes) pairs
def listFiles (dir : String) : IO (List (String × ByteArray)) := do
  let entries ← (dir : System.FilePath).readDir
  let mut files : List (String × ByteArray) := []
  for entry in entries do
    let info ← entry.path.metadata
    if info.type == IO.FS.FileType.file then
      let bytes ← IO.FS.readBinFile entry.path
      files := files ++ [(entry.path.toString, bytes)]
  return files
-- mccole: /list-files

-- mccole: snapshot-dir
-- Archive every regular file in srcDir to archiveDir
def snapshotDir (srcDir archiveDir : String) : IO Manifest := do
  IO.FS.createDirAll archiveDir
  let files ← listFiles srcDir
  snapshot files archiveDir
-- mccole: /snapshot-dir

-- mccole: main-dir
-- Entry point: archive a directory and report results
-- Run with: lean --run archive/archive_dir.lean
def main : IO Unit := do
  let archiveDir := "archive-dir"
  IO.println s!"Scanning current directory..."
  let manifest ← snapshotDir "." archiveDir
  IO.println s!"Archived {manifest.length} file(s) to {archiveDir}/"
  let blobs := (buildManifest (← listFiles ".")).2.length
  IO.println s!"Unique content blobs: {blobs}"
  IO.println "Done."
-- mccole: /main-dir
