import Lean
open Lean

-- getPerson tries to parse a JSON string, but it doesn't check whether
-- parsing succeeded before calling getStr. Fix the error handling.
def getPerson (jsonStr : String) : Option String :=
  -- BUG: Json.parse can fail, but the error is not checked
  let json : Json := match Json.parse jsonStr with
    | .ok v => v
    | .error _ => Json.null
  match json.getObjValAs? String "name" with
  | .ok name => some name
  | .error _ => none

#guard getPerson "{\"name\": \"Ada\"}" == some "Ada"
#guard (getPerson "not json at all").isNone
#guard (getPerson "{\"age\": 42}").isNone
