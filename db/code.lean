-- mccole: log-entry
-- A log entry: key paired with an optional value (none = deleted/tombstone)
abbrev LogEntry := String × Option String
abbrev Log := List LogEntry
-- mccole: /log-entry

-- mccole: db-set
-- Append a new value record to the log
def dbSet (log : Log) (key val : String) : Log :=
  log ++ [(key, some val)]
-- mccole: /db-set

-- mccole: db-del
-- Append a tombstone to mark a key as deleted
def dbDel (log : Log) (key : String) : Log :=
  log ++ [(key, none)]
-- mccole: /db-del

-- mccole: db-get
-- Scan newest-first: return the first value found for the key
def dbGet (log : Log) (key : String) : Option String :=
  Option.join ((List.reverse log).findSome? (β := Option String) fun (k, v) =>
    if k == key then some v else none)
-- mccole: /db-get

-- mccole: db-compact
-- Compact the log: keep only the most recent entry for each key
def dbCompact (log : Log) : Log :=
  let (_, kept) := (List.reverse log).foldl (init := ([], [])) fun (seen, acc) (k, v) =>
    if seen.contains k then (seen, acc)
    else (k :: seen, (k, v) :: acc)
  kept
-- mccole: /db-compact

-- mccole: check-key
-- Check if a key exists in the log (has a non-tombstone entry)
def dbExists (log : Log) (key : String) : Bool :=
  dbGet log key |>.isSome
-- mccole: /check-key

-- mccole: serialize
-- Serialize one entry as "key\tvalue\n" or "key\t\n" for tombstone
def serializeEntry (k : String) (v : Option String) : String :=
  s!"{k}\t{v.getD ""}\n"

-- Deserialize a "key\tvalue" line back into a LogEntry
def deserializeEntry (line : String) : Option LogEntry :=
  match line.splitOn "\t" with
  | [k, v] => some (k, if v.isEmpty then none else some v)
  | _       => none
-- mccole: /serialize

-- mccole: file-ops
-- Append one entry to a file
def appendEntry (path key : String) (val : Option String) : IO Unit := do
  let h ← IO.FS.Handle.mk path IO.FS.Mode.append
  h.putStr (serializeEntry key val)
  h.flush

-- Read entire log from a file
def readLog (path : String) : IO Log := do
  let text ← IO.FS.readFile path
  pure (text.splitOn "\n" |>.filterMap deserializeEntry)
-- mccole: /file-ops

-- mccole: tests
-- Tests ---------------------------------------------------------------

-- Set and get
#guard dbGet (dbSet [] "x" "1") "x" == some "1"

-- Latest write wins
#guard dbGet (dbSet (dbSet [] "x" "1") "x" "2") "x" == some "2"

-- Tombstone
#guard dbGet (dbDel (dbSet [] "x" "1") "x") "x" == none

-- Compact reduces redundant entries
def messyLog : Log := [("a", some "1"), ("b", some "1"), ("a", some "2"), ("b", none)]
#guard dbCompact messyLog == [("a", some "2"), ("b", none)]

-- Exists check
#guard dbExists (dbSet [] "x" "1") "x"
#guard !dbExists (dbDel (dbSet [] "x" "1") "x") "x"
#guard !dbExists [] "x"
-- mccole: /tests

-- mccole: main
-- Entry point: demonstrate the database in memory and on disk
-- Run with: lean --run db/code.lean
def main : IO Unit := do
  -- In-memory
  let log := dbSet (dbSet (dbSet [] "name" "Lean") "lang" "functional") "name" "Lean 4"
  IO.println s!"In-memory log: {log}"
  IO.println s!"  dbGet log \"name\" = {dbGet log "name"}"
  IO.println s!"  dbGet log \"lang\" = {dbGet log "lang"}"
  IO.println s!"  Compacted:     {dbCompact log}"

  -- File-backed: write to a log file, then read it back
  let path := "db/demo.log"
  IO.println s!"\nWriting to {path}..."
  appendEntry path "hello" (some "world")
  appendEntry path "count" (some "1")
  appendEntry path "count" (some "2")   -- latest write wins
  appendEntry path "tmp"   none          -- tombstone
  let diskLog ← readLog path
  IO.println s!"  Read from disk: {diskLog}"
  IO.println s!"  dbGet \"hello\" = {dbGet diskLog "hello"}"
  IO.println s!"  dbGet \"count\" = {dbGet diskLog "count"}"
  IO.println s!"  dbGet \"tmp\"   = {dbGet diskLog "tmp"}"
  IO.println "Done."
-- mccole: /main