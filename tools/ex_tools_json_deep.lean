import Lean
open Lean

-- Write a function that navigates into a nested JSON object given a list
-- of key names. Return none if any key is missing or the value is not an object.
-- ["a", "b"] means: get "a", then get "b" from that object.

def jsonDeepGet (j : Json) (keys : List String) : Option Json :=
  none  -- TODO

#guard
  let obj := Json.mkObj [("a", Json.mkObj [("b", Json.str "found")])]
  match jsonDeepGet obj ["a", "b"] with
  | some (Json.str s) => s == "found"
  | _ => false

#guard jsonDeepGet (Json.mkObj []) ["a"] == none
#guard jsonDeepGet (Json.str "hello") ["a"] == none

#guard
  let obj := Json.mkObj [("a", Json.mkObj [("b", Json.num 1)])]
  jsonDeepGet obj ["a", "b"] == some (Json.num 1)
