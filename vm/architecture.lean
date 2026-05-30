-- mccole: constants
/-- Number of general-purpose registers. -/
def NUM_REG : Nat := 4

/-- Number of addressable words in RAM. -/
def RAM_LEN : Nat := 256

/-- Mask to select one byte from a packed instruction word. -/
def OP_MASK : UInt32 := 0xFF

/-- Number of bits to shift when packing or unpacking instruction bytes. -/
def OP_SHIFT : UInt32 := 8
-- mccole: /constants

-- mccole: opcodes
def OP_HLT : UInt32 := 0x1  -- halt the program
def OP_LDC : UInt32 := 0x2  -- load a constant value into a register
def OP_LDR : UInt32 := 0x3  -- load from the RAM address held in a register
def OP_CPY : UInt32 := 0x4  -- copy one register's value into another
def OP_STR : UInt32 := 0x5  -- store a register value into RAM at address in register
def OP_ADD : UInt32 := 0x6  -- add two registers, writing result to first
def OP_SUB : UInt32 := 0x7  -- subtract second register from first
def OP_BEQ : UInt32 := 0x8  -- branch to address if register equals zero
def OP_BNE : UInt32 := 0x9  -- branch to address if register is not zero
def OP_PRR : UInt32 := 0xA  -- append register value to output
def OP_PRM : UInt32 := 0xB  -- append RAM value at address in register to output
-- mccole: /opcodes
