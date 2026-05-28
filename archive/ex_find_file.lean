-- Look up a file path in the manifest and return its hash (if present).
-- You may use the existing definitions from archive.lean.
abbrev Hash := String
abbrev Manifest := List (String × Hash)

def findFile (manifest : Manifest) (path : String) : Option Hash :=
  none

#guard findFile [("a.txt", "abc123"), ("b.txt", "def456")] "a.txt" == some "abc123"
#guard findFile [("a.txt", "abc123")] "c.txt" == none
#guard findFile [] "x.txt" == none