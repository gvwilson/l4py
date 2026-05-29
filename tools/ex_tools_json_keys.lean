import Lean
open Lean

-- Write a function that returns all keys in a JSON object as a list of strings
-- Return an empty list for non-object JSON values

def jsonKeys (j : Json) : List String :=
  []  -- TODO

#guard jsonKeys (Json.mkObj [("a", Json.num 1), ("b", Json.num 2)]) == ["a", "b"]
#guard jsonKeys (Json.mkObj []) == []
-- non-object returns empty list
#guard jsonKeys (Json.str "hello") == []
#guard jsonKeys (Json.arr #[]) == []
