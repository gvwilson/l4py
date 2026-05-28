-- Write a function that converts a ByteArray to a hex string.
-- Each byte becomes two hex characters (e.g., 0x1F -> "1f").
def hexDump (data : ByteArray) : String :=
  ""

def hexDigit (n : UInt8) : String :=
  let chars := "0123456789abcdef"
  s!"{chars[(n >>> 4).toNat]!}{chars[(n &&& 0xF).toNat]!}"

#guard hexDump (ByteArray.mk #[0x1F, 0xA0]) == "1fa0"
#guard hexDump ByteArray.empty == ""
#guard hexDump (ByteArray.mk #[0x00, 0xFF]) == "00ff"