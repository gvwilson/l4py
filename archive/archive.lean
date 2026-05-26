-- mccole: hash-abbrev
-- A content address is just a hex string of the hash
abbrev Hash := String
-- mccole: /hash-abbrev

-- mccole: manifest-abbrev
-- A manifest maps each original file path to its content hash
abbrev Manifest := List (String × Hash)
-- mccole: /manifest-abbrev

-- mccole: hash-bytes
-- Hash a ByteArray to a 16-character hex string
def hashBytes (ba : ByteArray) : Hash :=
  let h : UInt64 := hash ba
  let hex := "0123456789abcdef".toList
  let digits := (List.range 16).map fun i =>
    let nibble := (h >>> (60 - i * 4).toUInt64) &&& 0xF
    hex[nibble.toNat]!
  String.ofList digits
-- mccole: /hash-bytes

-- mccole: build-manifest
-- Pure: deduplicate a list of (path, bytes) pairs into (Manifest, blob store)
def buildManifest (files : List (String × ByteArray)) :
    Manifest × List (Hash × ByteArray) :=
  let entries := files.map fun (path, bytes) => (path, hashBytes bytes, bytes)
  let manifest := entries.map fun (path, h, _) => (path, h)
  let blobs := entries.foldl (init := []) fun acc (_, h, bytes) =>
    if acc.any (·.1 == h) then acc else acc ++ [(h, bytes)]
  (manifest, blobs)
-- mccole: /build-manifest

-- mccole: snapshot
-- IO: write each unique blob to a file named <hash>.bck
def snapshot (files : List (String × ByteArray)) (archiveDir : String) :
    IO Manifest := do
  let (manifest, blobs) := buildManifest files
  for (h, bytes) in blobs do
    IO.FS.writeBinFile s!"{archiveDir}/{h}.bck" bytes
  return manifest
-- mccole: /snapshot

-- mccole: restore
-- IO: read blobs from the archive and write them back to their original paths
def restore (manifest : Manifest) (archiveDir : String) : IO Unit := do
  for (path, h) in manifest do
    let bytes ← IO.FS.readBinFile s!"{archiveDir}/{h}.bck"
    IO.FS.writeBinFile path bytes
-- mccole: /restore

-- mccole: snapshot-dir
-- IO: snapshot all files in a directory (requires directory listing not in prelude)
-- In practice you'd use IO.FS.readDir from Std, but the prelude doesn't include it.
-- The pattern is: read directory → filter files → read bytes → call snapshot.
-- mccole: /snapshot-dir

-- mccole: tests
-- Tests (pure core) ---------------------------------------------------

def sampleFiles : List (String × ByteArray) := [
  ("a.txt", "hello".toUTF8),
  ("b.txt", "hello".toUTF8),   -- same content as a.txt
  ("c.txt", "world".toUTF8)
]

-- Two files with identical content should produce only two blobs
#guard (buildManifest sampleFiles).2.length == 2

-- Both a.txt and b.txt map to the same hash
#guard
  let (manifest, _) := buildManifest sampleFiles
  (manifest.find? (·.1 == "a.txt")).map (·.2) ==
  (manifest.find? (·.1 == "b.txt")).map (·.2)
-- mccole: /tests

-- mccole: main
-- Entry point: snapshot sample files to ./archive-dir, then restore them
-- Run with: lean --run archive/archive.lean
def main : IO Unit := do
  let archiveDir := "archive-dir"
  -- create the archive directory (ok if it already exists)
  IO.FS.createDirAll archiveDir
  IO.println s!"Snapshotting to {archiveDir}/"
  let manifest ← snapshot sampleFiles archiveDir
  IO.println s!"Created {manifest.length} manifest entries"
  IO.println "Restoring files..."
  restore manifest archiveDir
  IO.println "Done."
-- mccole: /main
