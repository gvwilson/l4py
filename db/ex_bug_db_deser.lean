-- deserializeEntry always wraps the value in some; should detect tombstones
def deserializeEntry (line : String) : Option (String × Option String) :=
  match line.splitOn "\t" with
  | [k, v] => some (k, some v)
  | _       => none

#guard deserializeEntry "key\tvalue" == some ("key", some "value")
#guard deserializeEntry "key\t"      == some ("key", none)
#guard deserializeEntry "bad"        == none