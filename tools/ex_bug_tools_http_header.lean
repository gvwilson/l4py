-- match code assumes the URL has a scheme; it doesn't handle the case
-- where scheme is missing. Fix the edge case.
def extractHost (url : String) : Option String :=
  -- BUG: does not handle case where "://" is missing
  let parts := url.splitOn "://"
  match parts with
  | scheme :: rest =>
    let hostPart := String.intercalate "://" rest
    match hostPart.splitOn "/" with
    | host :: _ => if host.isEmpty then none else some host
    | [] => none
  | [] => none

#guard extractHost "http://example.com/path" == some "example.com"
#guard extractHost "https://github.com/user/repo" == some "github.com"
-- The string "just-a-string" has no scheme; should return none
#guard (extractHost "just-a-string").isNone
#guard (extractHost "").isNone
