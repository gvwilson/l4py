-- mccole: env
-- Read an environment variable, falling back to a default when unset
def getEnvOr (key default : String) : IO String :=
  return (← IO.getEnv key) |>.getD default
-- mccole: /env

-- mccole: env-parse
-- Parse one "KEY=VALUE" line; skip blank lines and # comments
def parseLine (line : String) : Option (String × String) :=
  let t := line.trimAscii.toString
  if t.isEmpty || t.startsWith "#" then none
  else
    match t.splitOn "=" with
    | [] | [_] => none
    | k :: rest =>
      let key := k.trimAscii.toString
      -- rejoin with "=" in case the value itself contains "="
      let val := (String.intercalate "=" rest).trimAscii.toString
      if key.isEmpty then none else some (key, val)

-- Parse a .env-style file into a list of (key, value) pairs
def parseEnvFile (text : String) : List (String × String) :=
  text.splitOn "\n" |>.filterMap parseLine
-- mccole: /env-parse

-- mccole: tests
-- blank lines and comments are skipped
#guard parseLine ""        == none
#guard parseLine "# note"  == none

-- a simple KEY=VALUE line is parsed correctly
#guard parseLine "HOST=localhost" == some ("HOST", "localhost")

-- values may contain "=" (only the first "=" is the separator)
#guard parseLine "URL=http://x.com/a=b" == some ("URL", "http://x.com/a=b")

-- a multi-line file with blanks and a comment
#guard
  parseEnvFile "HOST=localhost\nPORT=5432\n# comment\n\nUSER=admin" ==
  [("HOST", "localhost"), ("PORT", "5432"), ("USER", "admin")]
-- mccole: /tests

-- mccole: main
def main : IO Unit := do
  -- Read individual environment variables
  let home ← getEnvOr "HOME" "(not set)"
  let user ← getEnvOr "USER" "(not set)"
  IO.println s!"HOME: {home}"
  IO.println s!"USER: {user}"
  -- Parse a .env-style config embedded as a string
  let config := "DB_HOST=localhost\nDB_PORT=5432\n# database name\nDB_NAME=myapp"
  IO.println "parsed config:"
  for (k, v) in parseEnvFile config do
    IO.println s!"  {k} = {v}"
-- mccole: /main
