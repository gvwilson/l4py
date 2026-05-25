-- Match on nested types: destructure an Option containing a List
def describeOptList (x : Option (List Int)) : String :=
  match x with
  | Option.none => "nothing"
  | Option.some [] => "empty list"
  | Option.some [n] => s!"singleton: {n}"
  | Option.some _ => "longer list"

#eval describeOptList Option.none
#eval describeOptList (Option.some [])
#eval describeOptList (Option.some [7])
#eval describeOptList (Option.some [1, 2, 3])
