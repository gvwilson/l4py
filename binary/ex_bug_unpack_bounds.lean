-- unpackStr doesn't check if the string body extends past the end of
-- the byte array. Add a bounds check so it returns none for truncated data.
def unpackInt32 (data : ByteArray) (offset : Nat) : Option (UInt32 × Nat) :=
  if offset + 4 ≤ data.size then
    let b0 := data[offset]!.toUInt32
    let b1 := data[offset + 1]!.toUInt32
    let b2 := data[offset + 2]!.toUInt32
    let b3 := data[offset + 3]!.toUInt32
    some (b0 ||| (b1 <<< 8) ||| (b2 <<< 16) ||| (b3 <<< 24), offset + 4)
  else
    none

def unpackStr (data : ByteArray) (offset : Nat) : Option (String × Nat) :=
  match unpackInt32 data offset with
  | none             => none
  | some (len, next) =>
    let n := len.toNat
    some (String.fromUTF8! (data.extract next (next + n)), next + n)

-- This should return none because the data is shorter than the length header claims.
#guard unpackStr (ByteArray.mk #[0xFF, 0x00, 0x00, 0x00]) 0 == none