import Lean
open Lean

-- mccole: json-build
-- Construct a JSON object with named fields
def makePerson (name : String) (age : Nat) : Json :=
  Json.mkObj [("name", Json.str name), ("age", Json.num age)]

-- Construct a JSON array of numbers
def makeScores (xs : List Nat) : Json :=
  Json.arr (xs.map (Json.num ∘ JsonNumber.fromNat)).toArray
-- mccole: /json-build

-- mccole: json-parse
-- Extract a String field; return none if absent or the wrong type
def getStr (j : Json) (key : String) : Option String :=
  match j.getObjValAs? String key with
  | .ok s    => some s
  | .error _ => none

-- Extract a Nat field; return none if absent or the wrong type
def getNat (j : Json) (key : String) : Option Nat :=
  match j.getObjValAs? Nat key with
  | .ok n    => some n
  | .error _ => none
-- mccole: /json-parse

-- mccole: tests
-- build: fields are accessible after construction
#guard
  let p := makePerson "Ada" 36
  getStr p "name" == some "Ada" && getNat p "age" == some 36

-- build: missing field returns none
#guard (getNat (makePerson "Euler" 76) "score").isNone

-- array: length matches the source list
#guard
  match makeScores [10, 20, 30] with
  | Json.arr vs => vs.size == 3
  | _           => false

-- parse: round-trip through a JSON string
#guard
  match Json.parse "{\"name\": \"Grace\", \"age\": 107}" with
  | .error _ => false
  | .ok v    => getStr v "name" == some "Grace" && getNat v "age" == some 107

-- parse: malformed input signals an error
#guard !(Json.parse "not json").isOk
-- mccole: /tests

-- mccole: main
def main : IO Unit := do
  -- Build and print
  let p := makePerson "Lean" 4
  IO.println s!"person: {p}"
  IO.println s!"scores: {makeScores [85, 92, 78]}"
  -- Parse a JSON string and extract fields
  match Json.parse "{\"name\": \"Turing\", \"age\": 41}" with
  | .error e => IO.println s!"parse error: {e}"
  | .ok v    =>
    let name := (getStr v "name").getD "?"
    let age  := (getNat v "age").getD  0
    IO.println s!"parsed: {name}, age {age}"
-- mccole: /main
