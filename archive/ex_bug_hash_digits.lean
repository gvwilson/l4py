-- hashBytes should produce correct hex digits, but the loop extracts
-- nibbles in the wrong order. The result is reversed. Fix it.
def hashBytes (ba : ByteArray) : String :=
  let h : UInt64 := hash ba
  let hex := "0123456789abcdef".toList
  let digits := (List.range 16).map fun i =>
    let nibble := (h >>> (i * 4).toUInt64) &&& 0xF
    hex[nibble.toNat]!
  String.ofList digits

#guard hashBytes "hello".toUTF8 == hashBytes "hello".toUTF8
#guard hashBytes "hello".toUTF8 != hashBytes "world".toUTF8