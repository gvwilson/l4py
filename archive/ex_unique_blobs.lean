-- Count how many unique blobs are in the blob store.
-- A blob store is a list of (hash, bytes) pairs.
abbrev Hash := String

def countUniqueBlobs (blobs : List (Hash × ByteArray)) : Nat :=
  0

def sampleBlobs : List (Hash × ByteArray) := [
  ("abc", "hello".toUTF8),
  ("def", "world".toUTF8),
  ("abc", "hello".toUTF8)   -- duplicate hash, same content
]

#guard countUniqueBlobs sampleBlobs == 2
#guard countUniqueBlobs [] == 0
#guard countUniqueBlobs [("x", "a".toUTF8)] == 1