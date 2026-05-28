-- packValue truncates the string length to 16 bits instead of 32 bits.
-- The length header is wrong for strings longer than 65535 bytes. Fix the
-- length type so it uses the full 32-bit range.
inductive Value where | int32 : UInt32 → Value | str : String → Value

def packInt32 (n : UInt32) : ByteArray :=
  ByteArray.mk #[
    (n           &&& 0xFF).toUInt8,
    ((n >>>  8)  &&& 0xFF).toUInt8,
    ((n >>> 16)  &&& 0xFF).toUInt8,
    ((n >>> 24)  &&& 0xFF).toUInt8
  ]

def packValue : Value → ByteArray
  | .int32 n => packInt32 n
  | .str s   =>
      let bytes := s.toUTF8
      packInt32 (bytes.size.toUInt16.toUInt32) ++ bytes

-- A 4-character string should encode length=4, not truncated.
#guard packValue (.str "test") ==
  ByteArray.mk #[0x04, 0x00, 0x00, 0x00, 0x74, 0x65, 0x73, 0x74]