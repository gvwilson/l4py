import architecture
import machine

-- mccole: ops
/-- Op code and operand format for one instruction.
    Format codes: "--" no operands, "r-" one register,
    "rr" two registers, "rv" register and value. -/
structure OpInfo where
  code : UInt32
  fmt  : String

/-- The complete instruction set, indexed by mnemonic. -/
def OPS : List (String × OpInfo) := [
  ("hlt", { code := OP_HLT, fmt := "--" }),
  ("ldc", { code := OP_LDC, fmt := "rv" }),
  ("ldr", { code := OP_LDR, fmt := "rr" }),
  ("cpy", { code := OP_CPY, fmt := "rr" }),
  ("str", { code := OP_STR, fmt := "rr" }),
  ("add", { code := OP_ADD, fmt := "rr" }),
  ("sub", { code := OP_SUB, fmt := "rr" }),
  ("beq", { code := OP_BEQ, fmt := "rv" }),
  ("bne", { code := OP_BNE, fmt := "rv" }),
  ("prr", { code := OP_PRR, fmt := "r-" }),
  ("prm", { code := OP_PRM, fmt := "r-" }),
]
-- mccole: /ops

-- mccole: helpers
/-- Parse "R0".."R3" into a register index, or return none. -/
def parseReg (token : String) : Option UInt32 :=
  if token.startsWith "R" then
    match (token.drop 1).toNat? with
    | some n => if n < NUM_REG then some n.toUInt32 else none
    | none   => none
  else none

/-- Parse a decimal literal or @label reference into a value, or return none. -/
def parseVal (token : String) (labels : List (String × Nat)) : Option UInt32 :=
  if token.startsWith "@" then
    let lbl := token.drop 1
    (labels.find? fun (k, _) => k == lbl).map fun (_, v) => v.toUInt32
  else
    token.toNat?.map (·.toUInt32)

/-- Pack a list of values into one word by shifting each new value in from the left.
    Mirrors Python's _combine: each successive call shifts the accumulator up by
    OP_SHIFT bits and ORs in the next argument. -/
def combine (args : List UInt32) : UInt32 :=
  args.foldl (fun acc a => (acc <<< OP_SHIFT) ||| a) 0
-- mccole: /helpers

-- mccole: labels
/-- Scan cleaned source lines and record the address of each label.
    Labels end with ":" and do not occupy any instruction slot. -/
def findLabels (lines : List String) : List (String × Nat) :=
  let go acc line :=
    let (labels, loc) := acc
    if line.endsWith ":" then
      ((line.dropRight 1 |>.trim, loc) :: labels, loc)
    else
      (labels, loc + 1)
  (lines.foldl go ([], 0)).1
-- mccole: /labels

-- mccole: compile
/-- Compile one instruction line into a packed word.
    Returns none if the mnemonic is unknown or operands are malformed. -/
def compileLine (line : String) (labels : List (String × Nat)) : Option UInt32 :=
  let tokens := (line.splitOn " ").filter (· != "")
  match tokens with
  | [] => none
  | mnem :: args =>
    match OPS.find? fun (name, _) => name == mnem with
    | none           => none
    | some (_, info) =>
      match info.fmt with
      | "--" => some (combine [info.code])
      | "r-" =>
        match args with
        | [r] => (parseReg r).map fun r0 => combine [r0, info.code]
        | _   => none
      | "rr" =>
        match args with
        | [r0s, r1s] =>
          match parseReg r0s, parseReg r1s with
          | some r0, some r1 => some (combine [r1, r0, info.code])
          | _,       _       => none
        | _ => none
      | "rv" =>
        match args with
        | [r0s, vs] =>
          match parseReg r0s, parseVal vs labels with
          | some r0, some v => some (combine [v, r0, info.code])
          | _,       _      => none
        | _ => none
      | _ => none
-- mccole: /compile

-- mccole: assemble
/-- Assemble a list of source lines into an array of instruction words.
    Strips blank lines and comments (lines beginning with #), resolves
    labels, and compiles each remaining line. Returns none if any line
    fails to compile. -/
def assemble (lines : List String) : Option (Array UInt32) := do
  let lines :=
    lines
    |>.map String.trim
    |>.filter (fun l => l != "" && !l.startsWith "#")
  let labels := findLabels lines
  let instrs := lines.filter (fun l => !l.endsWith ":")
  let words  ← instrs.mapM (fun l => compileLine l labels)
  return words.toArray
-- mccole: /assemble

-- mccole: asm-guards
-- Single hlt instruction encodes to op code 1 in the low byte.
#guard assemble ["hlt"] == some #[0x000001]

-- ldc R0 42: code=2, reg=0, val=0x2A → (0x2A << 16) | (0 << 8) | 2
#guard assemble ["ldc R0 42", "hlt"] == some #[0x2A0002, 0x000001]

-- Comments and blank lines are stripped before compilation.
#guard assemble ["# load then stop", "", "ldc R0 1", "hlt"] == some #[0x010002, 0x000001]
-- mccole: /asm-guards

-- mccole: integration
-- Assemble and run the count-up program: print 0, 1, 2 then halt.
#guard
  let src := [
    "ldc R0 0",     -- R0 = loop index, starting at 0
    "ldc R1 3",     -- R1 = loop limit
    "loop:",
    "prr R0",       -- print current index
    "ldc R2 1",     -- R2 = 1  (register-to-register add requires a register)
    "add R0 R2",    -- R0 += 1
    "cpy R2 R1",    -- R2 = R1 (copy limit; sub destroys its first operand)
    "sub R2 R0",    -- R2 = limit - index
    "bne R2 @loop", -- loop while R2 != 0
    "hlt"
  ]
  match assemble src with
  | none      => false
  | some prog =>
    match VMState.init prog with
    | none   => false
    | some s => (run 100 s).output == ["0", "1", "2"]
-- mccole: /integration
