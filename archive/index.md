# A File Archiver

<div class="callout" markdown="1">

-   Build a content-addressable file archiver like Git's object store
-   Hash files, deduplicate by content, and store blobs under their hash
-   Combine everything from previous lessons: types, pipelines, IO, and testing with `#guard`

</div>

-   A [%g content_addressable "content-addressable" %] store identifies files by their hash
    rather than their name
    -   Two files with the same content get the same address
    -   Like Git's `.git/objects` directory
-   We'll build it in layers: types first, then pure logic, then I/O
-   See the [JavaScript][sdxjs-archive] and [Python][sdxpy-archive] versions for comparison

## Type Aliases

[%inc archive.lean mark=hash-abbrev %]

-   `abbrev` creates a [%g type_alias "type alias" %] (a shorter name for an existing type)
    -   `Hash` and `String` are interchangeable
-   A content address is just a hex string of the file's hash

[%inc archive.lean mark=manifest-abbrev %]

-   A manifest maps original file paths to their content hashes
-   `List (String × Hash)` is a list of `(path, hash)` pairs
-   `abbrev` makes the intent clearer than writing `List (String × Hash)` everywhere

## Hashing Bytes

[%inc archive.lean mark=hash-bytes %]

-   `hashBytes` takes a `ByteArray` and returns a 16-character hex `Hash`
-   `hash` is Lean's built-in structural hash function
    -   Returns a `UInt64` (unsigned 64-bit integer)
    -   A real archiver would use SHA-256, but this is good enough for teaching
-   The body formats the `UInt64` into hex by extracting each 4-bit nibble
    -   `h >>> n` shifts the hash right by `n` bits
    -   `&&& 0xF` masks off the lowest 4 bits to get one hex digit
-   `String.ofList digits` converts the list of `Char` to a `String`
    -   `String.mk` would also work, but Lean now prefers `String.ofList`

## Building the Manifest

[%inc archive.lean mark=build-manifest %]

-   `buildManifest` is the [%g "pure" pure %] core of the archiver
    -   No I/O: takes data in, returns data out
    -   Hence the name "pure"
-   Step 1: hash every file's bytes and create `(path, hash, bytes)` triples
-   Step 2: extract just the `(path, hash)` pairs into the manifest
-   Step 3: deduplicate blobs by checking if a hash already exists in the accumulator
    -   `acc.any (·.1 == h)`: "does any entry in `acc` have `.1` equal to `h`?"
    -   `(·.1 == h)` uses the `·` placeholder for the tuple's first field
-   Returns a pair `(manifest, blobs)`
    -   `manifest` maps every path to its hash (even duplicates)
    -   `blobs` stores each unique `(hash, bytes)` pair only once

## Snapshot: Writing Files

[%inc archive.lean mark=snapshot %]

-   `snapshot` is an I/O function: note the `IO Manifest` return type
-   Calls the pure `buildManifest`, then writes each unique blob to disk
-   `for (h, bytes) in blobs do` iterates over the blob list (instead of recursing)
    -   Destructures each `(hash, bytes)` pair in the loop header
-   `IO.FS.writeBinFile` writes raw bytes to a file
    -   Like Python's `open(path, "wb").write(data)`
-   Each blob is saved as `archiveDir/<hash>.bck`
    -   The `.bck` extension is just a convention — like Git's loose object format
-   Returns the manifest so the caller can save or transmit it

## Restore: Reading Files Back

[%inc archive.lean mark=restore %]

-   `restore` reverses the process
    -   Read blobs from the archive
    -   Write them to original paths
-   `IO Unit` means "does I/O but returns nothing useful"
    -   Like a Python function that returns `None`
-   `←` captures the result of `IO.FS.readBinFile`
    -   Reading from disk is I/O, so we need the left arrow
-   `s!"{archiveDir}/{h}.bck"` constructs the blob path using string interpolation
-   Then `IO.FS.writeBinFile` writes the bytes back to the original file path

## Taking a Directory Snapshot

-   `snapshotDir` would read an entire directory and snapshot every file in it
-   The pattern is: list directory → filter to regular files → read each file → call `snapshot`

[%inc archive.lean mark=snapshot-dir %]

-   FIXME: show how to import the library and use Std here
-   The prelude doesn't include directory listing, so this section is a sketch
    -   `IO.FS.readDir` exists in `Std` but requires `import Std`
    -   We'll see imports in detail in a later lesson (DEBT)
-   The key idea: combine a directory reader with the archiver we already built

## Testing the Pure Core

[%inc archive.lean mark=tests %]

-   We can test the pure logic without touching the filesystem
    -   Because `buildManifest` is pure, tests are fast and deterministic
-   `sampleFiles` creates three files: `a.txt` and `b.txt` have identical content
-   `"hello".toUTF8` converts a string to a `ByteArray`
    -   Like Python's `"hello".encode("utf-8")`
-   First `#guard`: two identical files should produce only two blobs, not three
    -   `.2.length` accesses the blob list (second element of the pair) and counts it
-   Second `#guard`: `a.txt` and `b.txt` should map to the same hash
    -   `manifest.find? (·.1 == "a.txt")` finds the entry for `a.txt`
    -   `.map (·.2)` extracts the hash from the found entry
-   Both `#guard` expressions evaluate to `true`, so compilation succeeds silently

## The Full Picture

-   Forty lines of code implement a content-addressable archive
-   The design separates pure computation from I/O
    -   `buildManifest` can be tested without touching disk
    -   `snapshot` and `restore` do the actual reading and writing
-   This is the functional style in practice:
    -   Types describe the data (`Hash`, `Manifest`)
    -   Pure functions transform it (`buildManifest`)
    -   A thin I/O layer connects to the outside world

## Running the Program

[%inc archive.lean mark=main %]

-   `main` is the entry point when you run a Lean file as a program
    -   Like Python's `if __name__ == "__main__":` block
-   `IO.FS.createDirAll archiveDir` creates the archive directory
    -   Won't fail if the directory already exists
-   The steps match our earlier sections exactly: snapshot, then restore
-   `IO.println` outputs a line of text to stdout
-   `manifest.length` is the number of entries in the manifest

### Compiling and Running

-   To compile (check types, run `#eval` and `#guard`):
    -   `lake env lean archive/archive.lean`
    -   This is what we've been doing all along
    -   The `#guard` tests run at compile time
    -   `main` is not executed: it's just type-checked
-   To run the program (execute `main`):
    -   `lean --run archive/archive.lean`
    -   This compiles the file and calls the `main` function
-   After running, check the results:
    -   `ls archive-dir/` shows the `.bck` blob files
    -   Two files, because `a.txt` and `b.txt` are deduplicated
    -   `cat a.txt`, `cat b.txt`, `cat c.txt` show the restored content in the current directory
-   The two commands serve different purposes:
    -   `lake env lean` for development: type-check and test
    -   `lean --run` for execution: actually do the I/O

<div class="exercise" markdown="1">

## Exercises

### Write: Total File Size

Write a pure function `totalSize : Manifest × List (Hash × ByteArray) → Nat` that
returns the sum of all blob sizes (in bytes). Use `ByteArray.size` to get the size of
each blob.

<details markdown="1"><summary>hint</summary>

-   Extract the blob list from the pair with `.2`
-   Use `List.foldl` with `(· + ·)` and an initial value of `0`
-   Use `ByteArray.size` inside the map to convert bytes to sizes

</details>

### Write: Count Duplicates

Write a pure function `countDuplicates (files : List (String × ByteArray)) : Nat` that
returns how many files have content that also appears under another name. For the sample
data, this should return `2` (both `a.txt` and `b.txt` are duplicates of each other).

<details markdown="1"><summary>hint</summary>

-   Build the manifest with `buildManifest`
-   Group files by hash: for each hash, count how many paths map to it
-   Sum the counts for hashes that appear more than once

</details>

### Write: Manifest to String

Write `manifestToString : Manifest → String` that formats each entry as `"path:hash"`
with one entry per line. Use `String.intercalate "\n"` to join the lines.

<details markdown="1"><summary>hint</summary>

-   Use `List.map` to convert each `(path, hash)` pair to `s!"{path}:{hash}"`
-   Then `String.intercalate "\n"` to join with newlines

</details>

### Fix: Hash Digits in Wrong Order

[%inc ex_bug_hash_digits.lean %]

<details markdown="1"><summary>hint</summary>

-   `List.range 16` generates `[0, 1, …, 15]`, and `i * 4` shifts by 0, 4, 8, … bits each iteration
-   This extracts the nibbles from least-significant to most-significant, but prints them in that same order
-   The most-significant nibble should come first in the output
-   Reverse the shift: `60 - i * 4` to start from the top nibble

</details>

### Fix: Blobs Not Deduplicated

[%inc ex_bug_no_dedup.lean %]

<details markdown="1"><summary>hint</summary>

-   `entries.map` copies every blob, including duplicates
-   The original `buildManifest` uses `foldl` with a check: `if acc.any (·.1 == h) then acc else acc ++ [(h, bytes)]`
-   Add a similar deduplication step before collecting blobs

</details>

### Fix: Snapshot Missing Directory

[%inc ex_bug_snapshot.lean %]

<details markdown="1"><summary>hint</summary>

-   `IO.FS.writeBinFile` will fail if the parent directory doesn't exist
-   Add `IO.FS.createDirAll archiveDir` before the `for` loop
-   `createDirAll` won't fail if the directory already exists (like Python's `os.makedirs(exist_ok=True)`)

</details>

### Fix: Restore Uses Wrong Path

[%inc ex_bug_restore_path.lean %]

<details markdown="1"><summary>hint</summary>

-   The blob file is named `archiveDir/<hash>.bck`, not `archiveDir/<path>.bck`
-   The code uses `path` (the original filename) as the hash — that's wrong
-   Fix the destructuring: `for (path, h) in manifest do` and use `h` in the blob path

</details>

### Write: Find File in Manifest

[%inc ex_find_file.lean %]

<details markdown="1"><summary>hint</summary>

-   Use `List.find?` to search for the path in the manifest
-   The predicate is `fun (p, _) => p == path`
-   If found, extract the hash with `.map (·.2)`
-   `List.find?` already returns `Option`, so the result type matches

</details>

### Write: Count Unique Blobs

[%inc ex_unique_blobs.lean %]

<details markdown="1"><summary>hint</summary>

-   Extract all hashes from the blobs list, then deduplicate
-   Use `List.map` to get the hash list, then keep only the first occurrence of each
-   Same pattern as `dbCompact` from the [database lesson](@/db/): track seen hashes in a `foldl`
-   Return `List.length` of the deduplicated list

</details>

### Write: Find Files by Hash

[%inc ex_find_by_hash.lean %]

<details markdown="1"><summary>hint</summary>

-   Use `List.filter` to keep only entries where the hash matches
-   The predicate is `fun (_, h) => h == target`
-   Then use `List.map (·.1)` to extract just the file paths
-   Like finding all files that share the same content (deduplicated files)

</details>

### Write: Diff Two Manifests

[%inc ex_diff_manifest.lean %]

<details markdown="1"><summary>hint</summary>

-   Find paths that are in `old` but not in `new`
-   Use `List.filter` on the old manifest with a predicate that checks if the path exists in new
-   `new.any (fun (p, _) => p == path)` checks if a path exists in the new manifest
-   This is like comparing two snapshots to find renamed or deleted files

</details>

</div>
