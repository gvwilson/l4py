# A Database

<div class="callout" markdown="1">

-   Build a [%g log_structured "log-structured" %] key-value store with pure functional operations
-   Append new values and tombstones (deletion markers) to an immutable log
-   Query with newest-first scanning and compact with deduplication
-   Persist to disk using `IO.FS.Handle` with a simple line-based serialization format

</div>

-   Databases are the backbone of most applications
-   We'll build a minimal key-value store from first principles
-   Pure core that can be tested without touching disk (like [archive](@/archive/))
-   Builds on types from [types](@/types/), IO from [io](@/io/), and pipelines from [pipes](@/pipes/)

## Log Entries

[%inc code.lean mark=log-entry %]

-   A log entry is a `(key, value)` pair where the value is optional
    -   `some "val"`: the key has this value
    -   `none`: the key has been deleted (a [%g tombstone "tombstone" %])
-   `Log` is just a list of entries, newest at the end
-   `abbrev` creates transparent type aliases
    -   `LogEntry` and `String × Option String` are interchangeable
-   Like Git's commit history: each operation appends a new record
    -   Nothing is ever truly deleted until you compact

## Setting Values

[%inc code.lean mark=db-set %]

-   `dbSet` appends a new `(key, some val)` entry to the log
-   Does not modify or remove old entries — just adds at the end
-   The log only grows; old values are shadowed, not overwritten
-   Like Python's `log.append((key, val))` but returning a new list instead of mutating

## Deleting Values

[%inc code.lean mark=db-del %]

-   `dbDel` appends a tombstone: `(key, none)`
-   The key still appears in the log, but its value is now `none`
-   When queried, the tombstone indicates "this key was deleted"
-   Like setting a `deleted_at` timestamp in a soft-delete pattern

## Getting Values

[%inc code.lean mark=db-get %]

-   `dbGet` scans the log newest-first (reversed) and returns the first match
-   `List.reverse log` puts newest entries first
-   `findSome?` returns the first `some` result from the scan function
    -   The function returns `some v` when the key matches, `none` otherwise
-   `β := Option String` tells `findSome?` the inner type
-   `Option.join` flattens `Option (Option String)` to `Option String`
    -   `some (some "val")` → `some "val"` (key found with value)
    -   `some none` → `none` (tombstone found)
    -   `none` → `none` (key not in log)
-   Like Python's `next((v for k, v in reversed(log) if k == key), None)` but handling tombstones

## Compaction

[%inc code.lean mark=db-compact %]

-   `dbCompact` removes redundant entries, keeping only the newest per key
-   Algorithm: scan reversed log, keep first occurrence of each key
    -   `seen` tracks keys already encountered
    -   `kept` accumulates deduplicated entries in newest-first order
-   The result is in original order (newest last) because of double-reversal
    -   The fold processes reversed log (newest-first) and builds `kept` in reverse
    -   The final `kept` is already in original order
-   Like Python's `dict(reversed(log))` but preserving insertion order of last write

## Checking Key Existence

[%inc code.lean mark=check-key %]

-   `dbExists` checks if a key has a non-tombstone value
-   `dbGet log key |>.isSome` is `true` when the value is `some _`
-   Returns `false` for both missing keys and tombstoned keys

## Serialization

[%inc code.lean mark=serialize %]

-   `serializeEntry` formats an entry as `"key\tvalue\n"`
    -   For tombstones, value is empty: `"key\t\n"`
    -   `v.getD ""` extracts the value string, defaulting to `""` for `none`
-   `deserializeEntry` parses a line back into a `LogEntry`
    -   `line.splitOn "\t"` splits by the tab character
    -   Returns `none` for malformed lines (wrong number of fields)
-   Like CSV but with tabs as delimiters and no quoting

## File-Backed Operations

[%inc code.lean mark=file-ops %]

-   `appendEntry` opens a file in append mode and writes a serialized entry
    -   `IO.FS.Handle.mk path IO.FS.Mode.append` opens a file for appending
    -   `h.putStr` writes the string, `h.flush` ensures it's on disk
-   `readLog` reads the entire file and parses each line
    -   `IO.FS.readFile path` returns the file contents as a string
    -   `splitOn "\n"` breaks into lines
    -   `filterMap deserializeEntry` parses each line, discarding malformed ones
-   The file format is append-only: each new entry goes at the end
    -   You never rewrite the file in place
    -   Compaction to a new file is the only time you write a complete log

## Tests

[%inc code.lean mark=tests %]

-   `#guard` tests verify the pure operations
-   **Set and get**: writing a value and reading it back
-   **Latest write wins**: writing the same key twice returns the newer value
-   **Tombstone**: deleting a key returns `none`
-   **Compaction**: four entries reduce to two after deduplication
    -   `"a"` has two writes — only the latest (`"2"`) is kept
    -   `"b"` has a write then a tombstone — only the tombstone is kept
-   **Existence**: checks that `dbExists` returns correct boolean values

## Running the Program

[%inc code.lean mark=main %]

-   `main` demonstrates both in-memory and file-backed operations
-   In-memory: creates a log, queries it, compacts it
-   File-backed: writes entries to a file, reads them back, queries
    -   `IO.FS.removeFile` is not available in the prelude, so we skip cleanup
-   Compile and type-check with:
    -   `lake env lean db/code.lean`
-   Run interactively with:
    -   `lean --run db/code.lean`
-   The file-backed section creates a `db/demo.log` file
    -   You can inspect it with `cat db/demo.log`

<div class="exercise" markdown="1">

## Exercises

### Fix: Wrong Scan Direction

[%inc ex_bug_db_get_order.lean %]

<details markdown="1"><summary>hint</summary>

-   The function scans the log front-to-back, returning the oldest value
-   Reverse the log before scanning so the newest entry is found first
-   Use `List.reverse log` instead of `log`

</details>

### Fix: Compaction Loses Latest Value

[%inc ex_bug_db_compact_order.lean %]

<details markdown="1"><summary>hint</summary>

-   Scanning unreversed log keeps the *first* occurrence of each key (the oldest)
-   Reverse the log before folding so the newest entry is kept first
-   The final `kept` will already be in original order after the double-reversal

</details>

### Fix: Serialization Drops Tombstones

[%inc ex_bug_db_serialize.lean %]

<details markdown="1"><summary>hint</summary>

-   `v.getD "DELETED"` writes `"DELETED"` for tombstones instead of `""`
-   Tombstones should serialize as empty values so they're distinguishable from valid data
-   Use `v.getD ""` for an empty tombstone value

</details>

### Fix: Deserialization Ignores Empty Values

[%inc ex_bug_db_deser.lean %]

<details markdown="1"><summary>hint</summary>

-   The code always wraps the value in `some`, even for tombstones
-   Check `if v.isEmpty then none else some v` to detect tombstones
-   Empty value after the tab means "deleted"

</details>

### Fix: Missing `do` in Append

[%inc ex_bug_db_append.lean %]

<details markdown="1"><summary>hint</summary>

-   The function body has two IO actions but no `do` block
-   Add `do` after `:=` to sequence the handle creation, writing, and flushing

</details>

### Fix: Tombstone Not Matched

[%inc ex_bug_db_tombstone.lean %]

<details markdown="1"><summary>hint</summary>

-   `findSome?` returns the first `some` result, but the lambda returns `some v` only for matching keys
-   When a tombstone matches, `some none` is returned but `Option.join` is missing
-   Add `Option.join` to flatten the result and properly detect tombstones

</details>

### Write: Count Entries for a Key

[%inc ex_db_count_entries.lean %]

<details markdown="1"><summary>hint</summary>

-   Count how many times a key appears in the log (including tombstones)
-   Use `List.foldl` with a counter, or `List.filter` then `List.length`
-   `countEntries log "x"` should return the total number of `(k, v)` pairs where `k == "x"`

</details>

### Write: List All Unique Keys

[%inc ex_db_keys.lean %]

<details markdown="1"><summary>hint</summary>

-   Return a deduplicated list of all keys in the log
-   Use `List.map` to extract keys, then deduplicate
-   `keys` function: keep the first occurrence on reversed log (same pattern as `dbCompact`)

</details>

### Write: Merge Two Logs

[%inc ex_db_merge.lean %]

<details markdown="1"><summary>hint</summary>

-   Append one log to the other: `log1 ++ log2`
-   Entries from `log2` are newer and will shadow `log1` entries when queried
-   This is the simplest operation: just concatenate

</details>

### Write: Batch Update

[%inc ex_db_batch.lean %]

<details markdown="1"><summary>hint</summary>

-   Apply a list of `(key, value)` pairs to a log
-   Use `List.foldl` to iterate over the updates and call `dbSet` for each
-   `batchSet log [("x", "1"), ("y", "2")]` should add both entries

</details>

### Write: History for a Key

[%inc ex_db_history.lean %]

<details markdown="1"><summary>hint</summary>

-   Return all values for a key in chronological order (oldest first)
-   Filter the log to entries for the key, then extract values
-   Include `none` values (tombstones) in the history
-   Use `List.filterMap` to both filter and extract in one pass

</details>

### Write: Format Log as String

[%inc ex_db_dump.lean %]

<details markdown="1"><summary>hint</summary>

-   Convert the entire log to a human-readable string
-   Use `List.map` to format each entry: `s!"{k}: {v.getD "(deleted)"}"`
-   Join with `String.intercalate "\n"`
-   Like a simple database dump command

</details>

</div>
