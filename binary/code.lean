-- mccole: types
/-- A value that can be packed into binary form. -/
inductive Value where
  | int32 : UInt32 → Value
  | str   : String → Value
  deriving Repr, DecidableEq

/-- Format descriptor for unpacking: one tag per field in the byte stream. -/
inductive Fmt where
  | int32 : Fmt
  | str   : Fmt
  deriving Repr, DecidableEq
-- mccole: /types

-- mccole: pack-int
/-- Pack a 32-bit unsigned integer as 4 bytes, least-significant byte first (little-endian),
    matching Python's struct.pack("<I", n). -/
def packInt32 (n : UInt32) : ByteArray :=
  ByteArray.mk #[
    (n           &&& 0xFF).toUInt8,
    ((n >>>  8)  &&& 0xFF).toUInt8,
    ((n >>> 16)  &&& 0xFF).toUInt8,
    ((n >>> 24)  &&& 0xFF).toUInt8
  ]

#guard packInt32 31 == ByteArray.mk #[0x1F, 0x00, 0x00, 0x00]
#guard packInt32 65 == ByteArray.mk #[0x41, 0x00, 0x00, 0x00]
-- mccole: /pack-int

-- mccole: unpack-int
/-- Read a little-endian 32-bit unsigned integer from data at offset.
    Returns the value and the offset of the next byte. -/
def unpackInt32 (data : ByteArray) (offset : Nat) : Option (UInt32 × Nat) :=
  if offset + 4 ≤ data.size then
    let b0 := data[offset]!.toUInt32
    let b1 := data[offset + 1]!.toUInt32
    let b2 := data[offset + 2]!.toUInt32
    let b3 := data[offset + 3]!.toUInt32
    some (b0 ||| (b1 <<< 8) ||| (b2 <<< 16) ||| (b3 <<< 24), offset + 4)
  else
    none

#guard unpackInt32 (packInt32 31) 0 == some (31, 4)
#guard unpackInt32 (packInt32 0xDEADBEEF) 0 == some (0xDEADBEEF, 4)
-- mccole: /unpack-int

-- mccole: pack-str
/-- Pack a String as a 4-byte little-endian length followed by its UTF-8 bytes,
    matching Python's struct.pack("i", len(s)) + s.encode("utf-8"). -/
def packStr (s : String) : ByteArray :=
  let bytes := s.toUTF8
  packInt32 bytes.size.toUInt32 ++ bytes

#guard packStr "hi" == ByteArray.mk #[0x02, 0x00, 0x00, 0x00, 0x68, 0x69]
-- mccole: /pack-str

-- mccole: unpack-str
/-- Read a length-prefixed string from data at offset. -/
def unpackStr (data : ByteArray) (offset : Nat) : Option (String × Nat) :=
  match unpackInt32 data offset with
  | none             => none
  | some (len, next) =>
    let n := len.toNat
    if next + n ≤ data.size then
      some (String.fromUTF8! (data.extract next (next + n)), next + n)
    else
      none

#guard unpackStr (packStr "hello") 0 == some ("hello", 9)
-- mccole: /unpack-str

-- mccole: pack
/-- Pack a single Value into bytes. -/
def packValue : Value → ByteArray
  | .int32 n => packInt32 n
  | .str s   => packStr s

/-- Pack a list of heterogeneous values into a ByteArray. -/
def pack (values : List Value) : ByteArray :=
  values.foldl (init := ByteArray.empty) fun acc v => acc ++ packValue v
-- mccole: /pack

-- mccole: unpack
/-- Unpack values from a ByteArray given a list of format descriptors.
    Returns none if the buffer is too short or malformed. -/
def unpack (fmts : List Fmt) (data : ByteArray) : Option (List Value) :=
  let rec go : List Fmt → Nat → List Value → Option (List Value)
    | [],             _,   acc => some acc.reverse
    | .int32 :: rest, off, acc =>
      match unpackInt32 data off with
      | none            => none
      | some (n, off')  => go rest off' (.int32 n :: acc)
    | .str :: rest,   off, acc =>
      match unpackStr data off with
      | none            => none
      | some (s, off')  => go rest off' (.str s :: acc)
  go fmts 0 []
-- mccole: /unpack

-- mccole: guards
#guard
  let values := [Value.int32 31, .int32 65]
  unpack [.int32, .int32] (pack values) == some values

#guard
  let values := [Value.str "hello", .str "Python"]
  unpack [.str, .str] (pack values) == some values

#guard
  let values := [Value.int32 31, .str "hello", .int32 65, .str "Python"]
  unpack [.int32, .str, .int32, .str] (pack values) == some values
-- mccole: /guards
