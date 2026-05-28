-- Tombstones serialize as "DELETED", but should serialize as empty string
def serializeEntry (k : String) (v : Option String) : String :=
  s!"{k}\t{v.getD "DELETED"}\n"

def deserializeEntry (line : String) : Option (String × Option String) :=
  match line.splitOn "\t" with
  | [k, v] => some (k, if v.isEmpty then none else some v)
  | _       => none

#guard deserializeEntry (serializeEntry "x" none) == some ("x", none)
#guard deserializeEntry (serializeEntry "x" (some "y")) == some ("x", some "y")