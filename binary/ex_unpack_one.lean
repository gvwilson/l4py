-- Write a convenience function that unpacks exactly one value.
-- It should wrap the 'unpack' function to only accept single-element
-- format lists and return the value directly.

-- Assume these definitions exist (from code.lean):
--   unpack : List Fmt → ByteArray → Option (List Value)

-- Write a wrapper that expects exactly one Fmt and returns Option Value.
inductive Value where | int32 : UInt32 → Value | str : String → Value

def unpackOne (fmt : Fmt) (data : ByteArray) : Option Value :=
  none

inductive Fmt where | int32 : Fmt | str : Fmt