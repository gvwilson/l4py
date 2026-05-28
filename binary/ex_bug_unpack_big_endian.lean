-- unpackInt32 reads bytes in big-endian order, but packInt32 writes
-- little-endian. The values don't round-trip. Fix the shift order.
def packInt32 (n : UInt32) : ByteArray :=
  ByteArray.mk #[
    (n           &&& 0xFF).toUInt8,
    ((n >>>  8)  &&& 0xFF).toUInt8,
    ((n >>> 16)  &&& 0xFF).toUInt8,
    ((n >>> 24)  &&& 0xFF).toUInt8
  ]

def unpackInt32 (data : ByteArray) (offset : Nat) : Option (UInt32 × Nat) :=
  if offset + 4 ≤ data.size then
    let b0 := data[offset]!.toUInt32
    let b1 := data[offset + 1]!.toUInt32
    let b2 := data[offset + 2]!.toUInt32
    let b3 := data[offset + 3]!.toUInt32
    some ((b0 <<< 24) ||| (b1 <<< 16) ||| (b2 <<< 8) ||| b3, offset + 4)
  else
    none

#guard unpackInt32 (packInt32 31) 0 == some (31, 4)