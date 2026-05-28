-- buildManifest should deduplicate blobs by hash, but it keeps every
-- blob entry instead. The blob store has duplicates. Fix the dedup check.
abbrev Hash := String

def hashBytes (ba : ByteArray) : Hash :=
  toString (hash ba)

def buildManifest (files : List (String × ByteArray)) :
    List (String × Hash) × List (Hash × ByteArray) :=
  let entries := files.map fun (path, bytes) => (path, hashBytes bytes, bytes)
  let manifest := entries.map fun (path, h, _) => (path, h)
  let blobs := entries.map fun (_, h, bytes) => (h, bytes)
  (manifest, blobs)

def sample : List (String × ByteArray) := [
  ("a.txt", "hello".toUTF8),
  ("b.txt", "hello".toUTF8),   -- same content as a.txt
  ("c.txt", "world".toUTF8)
]

#guard (buildManifest sample).2.length == 2