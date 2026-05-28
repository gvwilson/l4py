-- Write a function that takes a list of Values and produces
-- the matching list of Fmt descriptors.
inductive Value where | int32 : UInt32 → Value | str : String → Value
inductive Fmt where | int32 : Fmt | str : Fmt

def fmtsOf (vals : List Value) : List Fmt :=
  []

#guard fmtsOf [Value.int32 0, Value.str ""] == [Fmt.int32, Fmt.str]
#guard fmtsOf [Value.str "x", Value.int32 42, Value.str "y"] == [Fmt.str, Fmt.int32, Fmt.str]
#guard fmtsOf [] == []