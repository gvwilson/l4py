import Lean
open Lean

-- getStr looks up the wrong key; fix the lookup
def makePerson (name : String) (age : Nat) : Json :=
  Json.mkObj [("name", Json.str name), ("age", Json.num age)]

-- BUG: looks up "Name" (capital N) instead of "name"
def getStr (j : Json) (key : String) : Option String :=
  match j.getObjValAs? String "Name" with
  | .ok s  => some s
  | .error _ => none

-- extracting the name field should return the value passed to makePerson
#guard getStr (makePerson "Euler" 76)  "name" == some "Euler"
#guard getStr (makePerson "Noether" 53) "name" == some "Noether"

-- extracting a missing key should return none
#guard (getStr (makePerson "Gauss" 77) "email").isNone
