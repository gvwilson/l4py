-- parseEnvFile doesn't trim whitespace from keys or values. A line like
-- "  HOST = localhost  " should parse correctly. Fix the trimming.
def parseLine (line : String) : Option (String × String) :=
  -- BUG: no trimming, so "  HOST = localhost  " fails
  if line.isEmpty || line.startsWith "#" then none
  else
    match line.splitOn "=" with
    | [] | [_] => none
    | k :: rest =>
      let key := k
      let val := String.intercalate "=" rest
      if key.isEmpty then none else some (key, val)

def parseEnvFile (text : String) : List (String × String) :=
  text.splitOn "\n" |>.filterMap parseLine

#guard parseLine "HOST=localhost" == some ("HOST", "localhost")
#guard parseLine "  HOST = localhost  " == some ("HOST", "localhost")
#guard parseLine "# comment" == none

#guard
  parseEnvFile "  KEY = value  \n\n# note\nPORT=8080" ==
  [("KEY", "value"), ("PORT", "8080")]
