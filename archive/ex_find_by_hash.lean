-- Find all file paths in the manifest that have the given hash.
abbrev Hash := String
abbrev Manifest := List (String × Hash)

def findByHash (manifest : Manifest) (target : Hash) : List String :=
  []

def m : Manifest := [("a.txt", "abc"), ("b.txt", "def"), ("c.txt", "abc")]

#guard findByHash m "abc" == ["a.txt", "c.txt"]
#guard findByHash m "xyz" == []
#guard findByHash [] "abc" == []