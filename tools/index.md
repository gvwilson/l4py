# Tools

<div class="callout" markdown="1">

-   Draw on OS entropy with `IO.getRandomBytes` for non-deterministic sampling
-   Parse and construct JSON with `Lean.Json` from the built-in Lean meta library
-   Fetch remote data over plain HTTP with `Std.Internal.Http` and `Std.Internal.Async.TCP`
-   Read configuration from environment variables with `IO.getEnv`

</div>

-   The lessons so far have built tools from scratch: functions, key-value stores, binary packers
-   Most real programs use existing libraries for common tasks
-   Lean's standard library and meta library cover randomness, structured data, and process I/O

## True Randomness

[%inc random.lean mark=random %]

-   `IO.getRandomBytes` reads from the operating system's entropy pool
    -   E.g., on Linux this is `/dev/urandom`
    -   The result is different on every call:
	    unlike the [%g rng "random number generator" %] (RNG) in [the DES lesson](@/des/) there is no seed
    -   Which means it is *deliberately* not reproducible
-   `randomBytes` folds the byte list into a single `Nat`, treating the bytes as a base-256 number
    -   4 bytes give 32 bits of range: 0 to 4,294,967,295
-   `randomInRange` maps that range to [lo, hi] with modulo arithmetic
    -   The divisor is `hi - lo + 1` (not `hi - lo`) so `hi` is reachable
    -   Like Python's `random.randint(lo, hi)` — both bounds are inclusive
-   True randomness is appropriate when the result must be unpredictable
    -   Use a seeded RNG when reproducibility matters

[%inc random.lean mark=tests %]

[%inc random.lean mark=main %]
[%inc random.out %]

-   The dice roll and colour change every run
-   the `.out` file shows one particular execution

## Building and Parsing JSON

[%inc json.lean mark=json-build %]
[%inc json.lean mark=json-parse %]

-   `import Lean` makes `Lean.Json` available; `open Lean` drops the `Lean.` prefix
-   `Json.mkObj` takes a list of `(String, Json)` pairs and returns a JSON object
    -   The key order in the output may differ from the input order
-   `Json.arr` takes an `Array Json` and returns a JSON array
    -   `JsonNumber.fromNat` converts a `Nat` to the `JsonNumber` type that `Json.num` expects
-   `getObjValAs? α key` extracts a field as type `α` using the `FromJson` type class
    -   Returns `Except.ok value` on success and `Except.error message` on failure
    -   `getStr` and `getNat` wrap this in `Option` for convenience
-   Like Python's `json.loads` and `json.dumps` but with types checked at extraction time

[%inc json.lean mark=tests %]

[%inc json.lean mark=main %]
[%inc json.out %]

## Fetching Data with HTTP

[%inc http.lean mark=http %]

-   `import Std.Internal.Http.Data.URI` parses URLs; `import Std.Internal.Async.TCP` and `DNS` handle transport
-   `URI.parse? url` returns `Option URI`; `.authority` holds the host and port
    -   `URI.Scheme.defaultPort` supplies port 80 for HTTP when the URL omits one
-   `DNS.getAddrInfo host "http"` resolves a hostname to IP addresses (returns `Async (Array IPAddr)`)
    -   `.block` runs an `Async` computation synchronously and returns the result
-   `Request.get target |>.header! key val` builds an HTTP/1.1 request using a fluent builder
    -   `.line` extracts the finished `Request.Head`; `Encode.encode` serializes it to bytes
-   `client.recv? 4096` reads up to 4096 bytes; `none` signals end-of-stream
-   Returning `Option String` lets callers handle failure with `match` rather than exceptions
-   Like Python's `requests.get(url).text` but with explicit DNS, TCP, and encoding steps
-   HTTPS is not supported; use a plain `http://` URL

[%inc http.lean mark=main %]
[%inc http.out %]

-   Pass a different URL as the first argument: `lake env lean --run tools/http.lean http://...`

## Environment Variables

[%inc env.lean mark=env %]

-   `IO.getEnv key` returns `IO (Option String)` — `none` when the variable is not set
    -   Like Python's `os.environ.get(key)` — both return `None` for absent variables
-   `getEnvOr` unwraps the `Option` with `|>.getD default`, a pipeline version of `getD`
    -   `(← IO.getEnv key) |>.getD default` reads as "get env key, then default-unwrap it"

[%inc env.lean mark=env-parse %]

-   `parseLine` handles the three cases: blank/comment → `none`, valid `KEY=VALUE` → `some`
    -   Splitting on `"="` and rejoining the tail with `String.intercalate` preserves `=` in values
-   `parseEnvFile` chains `splitOn "\n"` and `filterMap` to process every line in one pass
-   Like Python's `dotenv.dotenv_values(path)` but as a pure function on a string

[%inc env.lean mark=tests %]

[%inc env.lean mark=main %]
[%inc env.out %]

<div class="exercise" markdown="1">

## Exercises

### Fix: Range Missing Its Top Value

[%inc ex_bug_tools_range.lean %]

<details markdown="1"><summary>hint</summary>

-   `raw % (hi - lo)` produces values in `[0, hi - lo - 1]`, so the offset lands in `[lo, hi - 1]`
-   Change the divisor to `hi - lo + 1` so the full range `[0, hi - lo]` is possible
-   With `raw = hi - lo` as a test case, `(hi - lo) % (hi - lo + 1) == hi - lo`, giving `lo + (hi - lo) = hi`

</details>

### Fix: Wrong JSON Key Name

[%inc ex_bug_tools_json.lean %]

<details markdown="1"><summary>hint</summary>

-   The function looks up `"Name"` (capital N) but JSON keys are case-sensitive
-   `makePerson` stores the field as `"name"` (lower case)
-   Change the literal `"Name"` to the `key` parameter that is passed in

</details>

### Write: Pick From a List

[%inc ex_tools_pick.lean %]

<details markdown="1"><summary>hint</summary>

-   Return `none` for an empty list: `if xs.isEmpty then none`
-   Otherwise use `xs[i % xs.length]!` to wrap the index around
-   `List.get?` is an alternative but requires a `Fin`; the `!` accessor with modulo is simpler

</details>

### Write: List JSON Object Keys

[%inc ex_tools_json_keys.lean %]

<details markdown="1"><summary>hint</summary>

-   `Json` has a constructor `Json.obj m` where `m` is a `Std.TreeMap.Raw String Json compare`
-   Call `m.toList` to get a `List (String × Json)`, then `.map Prod.fst` to extract just the keys
-   Match on `| Json.obj m => ...` and return `[]` for all other constructors

</details>

### Fix: Unchecked JSON Parse Error

[%inc ex_bug_tools_parse_error.lean %]

<details markdown="1"><summary>hint</summary>

-   `Json.parse` returns `Except error json` — the error case is lost
-   Replace `let json : Json := …` with `match Json.parse jsonStr with`
-   Return `none` in the `| .error _ =>` case before trying to extract fields

</details>

### Fix: URL Without Scheme

[%inc ex_bug_tools_http_header.lean %]

<details markdown="1"><summary>hint</summary>

-   `splitOn "://"` on `"just-a-string"` returns `["just-a-string"]` — a one-element list
-   The match arms assume at least two parts: `scheme :: rest`
-   Add a guard: `if parts.length < 2 then none` before destructuring

</details>

### Fix: Untrimmed Env Keys and Values

[%inc ex_bug_tools_env_trim.lean %]

<details markdown="1"><summary>hint</summary>

-   `"  HOST = localhost  "` has whitespace around both key and value
-   Call `.trimAscii` (or `.trim`) on `k` before the key check
-   Also trim `val` before returning the pair
-   The existing `parseLine` in the lesson already does this — compare with `env.lean`

</details>

### Write: Password Generator

[%inc ex_tools_password.lean %]

<details markdown="1"><summary>hint</summary>

-   Use a simple LCG: `seed' = (1664525 * seed + 1013904223) % 4294967296`
-   Pick one character using `pickChar alphabet seed`, then advance the seed
-   Recurse or use `List.range length` with a `foldl` accumulator
-   `foldl` pattern: start with `("", seed)`, for each step pick a char and update both

</details>

### Write: JSON Deep Get

[%inc ex_tools_json_deep.lean %]

<details markdown="1"><summary>hint</summary>

-   If `keys` is empty, return `some j` (the current value)
-   Otherwise, match `keys` as `k :: rest`: check if `j` is `Json.obj m`
-   Use `m.toList.find? (·.1 == k)` to look up the next key
-   Then recurse with `rest` on the found value, or return `none` if the key is missing

</details>

### Write: URL Query Parser

[%inc ex_tools_url_query.lean %]

<details markdown="1"><summary>hint</summary>

-   Find `"?"` in the URL: `url.splitOn "?"`
-   If there are fewer than 2 parts, return `[]` (no query string)
-   Split the query part on `"&"`, then split each pair on `"="`
-   For a pair without `"="` (like `"flag"`), use `""` as the value
-   Use `filterMap` to handle malformed pairs

</details>

</div>
