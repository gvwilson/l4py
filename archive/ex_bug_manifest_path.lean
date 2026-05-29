-- buildManifest constructs the manifest, but the path and hash are mispaired.
-- The entry for each file should contain (path, hash). Fix the pairing.
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
  -- BUG: manifest pairs each path with the wrong file's hash
  -- The manifest is built by zipping paths with the *reversed* hash list
  let hashes := entries.map fun (_, h, _) => h
  let manifest := List.zip
    (entries.map fun (p, _, _) => p)
    hashes.reverse
  let blobs := entries.foldl (init := []) fun acc (_, h, bytes) =>
    if acc.any (·.1 == h) then acc else acc ++ [(h, bytes)]
  (manifest, blobs)

#guard
  let files := [("a.txt", "hello".toUTF8), ("b.txt", "world".toUTF8)]
  let (manifest, _) := buildManifest files
  (manifest.find? (·.1 == "a.txt")).map (·.2) == some (hashBytes "hello".toUTF8)

#guard
  let files := [("a.txt", "hello".toUTF8), ("b.txt", "hello".toUTF8)]
  let (manifest, _) := buildManifest files
  (manifest.find? (·.1 == "a.txt")).map (·.2) ==
  (manifest.find? (·.1 == "b.txt")).map (·.2)
