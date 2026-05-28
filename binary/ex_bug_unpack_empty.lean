-- unpack of an empty format list should return some [] but it returns
-- none. Fix the base case.
inductive Value where | int32 : UInt32 → Value | str : String → Value
inductive Fmt where | int32 : Fmt | str : Fmt

def unpack (fmts : List Fmt) (_data : ByteArray) : Option (List Value) :=
  match fmts with
  | []     => none
  | _ :: _ => none   -- stub; real implementation would recurse

#guard unpack [] (ByteArray.mk #[1, 2, 3]) == some []