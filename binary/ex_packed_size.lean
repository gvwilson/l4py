-- Write a function that computes the number of bytes a list of Values
-- would occupy when packed, without actually calling 'pack'.
inductive Value where | int32 : UInt32 → Value | str : String → Value

def packedSize (vals : List Value) : Nat :=
  0

#guard packedSize [Value.int32 42, Value.int32 65] == 8
#guard packedSize [Value.str "hi"] == 6    -- 4 (length) + 2 (bytes)
#guard packedSize [] == 0