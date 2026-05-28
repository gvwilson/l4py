-- Compare two manifests. Return the paths that appear in the first
-- manifest but not the second (new or renamed files).
abbrev Hash := String
abbrev Manifest := List (String × Hash)

def diffManifests (old new : Manifest) : List String :=
  []

def oldManifest : Manifest := [("a.txt", "abc"), ("b.txt", "def")]
def newManifest : Manifest := [("a.txt", "abc"), ("c.txt", "xyz")]

#guard diffManifests oldManifest newManifest == ["b.txt"]
#guard diffManifests newManifest oldManifest == ["c.txt"]
#guard diffManifests [] [] == []