-- Prove that byte values stay below 256 when each input is below 128
theorem safeByteAdd (a b : Nat) (ha : a < 128) (hb : b < 128) : a + b < 256 := by omega

-- Verify a hexadecimal constant matches its decimal value at compile time
theorem hexDecimal : 0xFF = 255 := by decide

-- Prove a list of valid HTTP status codes has the expected length
def successCodes : List Nat := [200, 201, 202, 204]
theorem fourSuccessCodes : successCodes.length = 4 := by decide
