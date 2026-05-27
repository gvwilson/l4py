# Binary Data

## Outline

-   Programs usually store integers as fixed-width binary values rather than decimal strings
-   Binary packing converts heterogeneous values into a compact byte sequence
    for storage or transmission
-   A format descriptor tells the unpacker how to reconstruct each value from raw bytes
-   Variable-length data like strings needs a fixed-width length header so the reader
    knows where each value ends

## Packable Values

[%inc code.lean mark=types %]

-   `Value` is a sum type:
    each value is either a 32-bit unsigned integer or a UTF-8 string
-   `Fmt` mirrors `Value` but carries no data — it is the blueprint used during unpacking
-   `deriving Repr` lets Lean print values in `#eval`; `deriving DecidableEq` lets `==`
    work in `#guard` tests
-   Like Python's `struct` format strings (`"I"` for unsigned 32-bit, `"s"` for bytes),
    but checked at compile time

## Packing Integers

[%inc code.lean mark=pack-int %]

-   Little-endian byte order: least-significant byte first, matching most modern hardware
-   `n &&& 0xFF` masks the lowest 8 bits; `n >>> 8` shifts right by one byte
-   Applying those two operations four times extracts each byte in turn
-   Like Python's `struct.pack("<I", 31)`, which produces `b'\x1f\x00\x00\x00'`
-   The `#guard` checks confirm that 31 (`0x1F`) and 65 (`0x41`) each land in the
    first byte, with the remaining three bytes zero

## Unpacking Integers

[%inc code.lean mark=unpack-int %]

-   `data[offset]!` reads one byte, panicking if out of bounds (the bounds check comes first)
-   `.toUInt32` widens each byte before shifting to avoid truncation
-   OR-ing the shifted bytes reassembles the original 32-bit value
-   `offset + 4` advances past the four bytes just consumed, ready for the next field
-   The second `#guard` uses `0xDEADBEEF` to verify that all four bytes survive the
    round trip, not just the low byte

## Packing Strings

[%inc code.lean mark=pack-str %]

-   `s.toUTF8` converts the `String` to a `ByteArray` using UTF-8 encoding
-   `bytes.size.toUInt32` converts the byte count from `Nat` to `UInt32` for the header
-   The 4-byte length header lets the reader know how many bytes of content follow
-   Compatible with Python's `pack("i", len(s)) + s.encode("utf-8")` from
    `variable_packing.py` in the Python version of this lesson

## Unpacking Strings

[%inc code.lean mark=unpack-str %]

-   Read the length first with `unpackInt32`, then slice exactly that many bytes
-   `data.extract start stop` returns bytes from `start` up to but not including `stop`
-   `String.fromUTF8!` decodes UTF-8 bytes back into a `String`; it panics on
    invalid UTF-8 (DEBT: show the safe `String.fromUTF8?` variant)
-   The function can fail at two points: missing length header, or truncated body;
    both return `none`

## Packing a List

[%inc code.lean mark=pack %]

-   `packValue` dispatches on the `Value` constructor and calls the right helper
-   `pack` folds over the list, appending each packed value to the accumulator
-   Order is preserved: the first value in the list becomes the first bytes in the array
-   Like Python's `struct.pack(fmt, *values)`, but the format is inferred from the
    values themselves rather than written as a separate string

## Unpacking a List

[%inc code.lean mark=unpack %]

-   `go` recurses on the format list, consuming bytes starting at `off`
-   Results accumulate in reverse order in `acc`; `acc.reverse` corrects that at the end
-   If `unpackInt32` or `unpackStr` returns `none`, `go` propagates `none` immediately
-   The format list must exactly match the structure of the packed data — there is no
    self-describing header (unlike JSON or pickle)

## Round-Trip Tests

[%inc code.lean mark=guards %]

-   Three tests: two integers only, two strings only, then a mixed list
-   `#guard` runs at compile time; a passing guard produces no output
-   If any `#guard` fails, the file does not compile — there is no separate test runner

## Example Program

[%inc example.lean mark=main %]

-   `import code` brings in the library from the same Lake package (DEBT: explain Lake)
-   Pack two integers followed by two strings; the total is 27 bytes
    (4 + 4 + 4+5 + 4+6)
-   The format list `[.int32, .int32, .str, .str]` must match the order used in `pack`
-   Run with `lake exe example` from the `binary/` directory

<div class="exercise" markdown="1">

## Exercises

### Pack a Bool (15 min)

Add a `| bool : Bool → Value` constructor to `Value` and a matching `| bool : Fmt`
constructor to `Fmt`. Represent `true` as the byte `1` and `false` as `0`.
Implement `packBool` and `unpackBool`, then extend `packValue` and `unpack` to handle
the new constructor. Add `#guard` tests for round-trips of both `true` and `false`.

### Detect Format Mismatch (15 min)

What does `unpack [.str] (pack [Value.int32 42])` return, and why? Write a `#guard`
that confirms the answer, then explain in a comment why that behavior could be
dangerous in a real system.

### Count Bytes (10 min)

Write a pure function `packedSize (fmts : List Fmt) (values : List Value) : Nat`
that computes the number of bytes `pack values` would produce *without* actually
calling `pack`. For `int32`, the size is always 4. For `str`, it is 4 plus the
byte length of the string's UTF-8 encoding. Add a `#guard` that checks the result
against `(pack someValues).size` for a mixed list.

</div>
