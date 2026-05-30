import architecture

-- mccole: state
/-- The complete state of the virtual machine at one moment in time. -/
structure VMState where
  ip     : Nat           -- address of the next instruction to fetch
  reg    : Array UInt32  -- NUM_REG general-purpose registers
  ram    : Array UInt32  -- RAM_LEN words of addressable memory
  output : List String   -- lines produced by prr and prm instructions
  deriving Repr
-- mccole: /state

-- mccole: init
/-- Create a fresh VM state with the given program loaded starting at address 0.
    Returns none if the program is longer than RAM_LEN words. -/
def VMState.init (program : Array UInt32) : Option VMState :=
  if program.size > RAM_LEN then none
  else
    let ram := (Array.range RAM_LEN).map fun i => program.getD i 0
    some { ip := 0, reg := Array.mkArray NUM_REG 0, ram, output := [] }
-- mccole: /init

-- mccole: fetch
/-- Read the instruction at the current IP, advance IP by one, and return
    the decoded (op, arg0, arg1) triple together with the updated state.
    Instructions are packed as three bytes: op in bits 7-0, arg0 in 15-8,
    arg1 in 23-16. -/
def VMState.fetch (s : VMState) : (UInt32 × UInt32 × UInt32) × VMState :=
  let instr := s.ram[s.ip]!
  let op    := instr &&& OP_MASK
  let arg0  := (instr >>> OP_SHIFT) &&& OP_MASK
  let arg1  := (instr >>> (OP_SHIFT * 2)) &&& OP_MASK
  ((op, arg0, arg1), { s with ip := s.ip + 1 })
-- mccole: /fetch

-- mccole: step
/-- Execute one instruction and return the updated state,
    or none if the instruction was hlt. -/
def VMState.step (s : VMState) : Option VMState :=
  let ((op, arg0, arg1), s') := s.fetch
  let i0 := arg0.toNat
  let i1 := arg1.toNat
  -- mccole: hlt
  if op == OP_HLT then none
  -- mccole: /hlt
  -- mccole: ldc
  else if op == OP_LDC then
    some { s' with reg := s'.reg.set! i0 arg1 }
  -- mccole: /ldc
  else if op == OP_LDR then
    some { s' with reg := s'.reg.set! i0 (s'.ram[s'.reg[i1]!.toNat]!) }
  else if op == OP_CPY then
    some { s' with reg := s'.reg.set! i0 s'.reg[i1]! }
  -- mccole: str
  else if op == OP_STR then
    some { s' with ram := s'.ram.set! (s'.reg[i1]!.toNat) s'.reg[i0]! }
  -- mccole: /str
  -- mccole: add
  else if op == OP_ADD then
    some { s' with reg := s'.reg.set! i0 (s'.reg[i0]! + s'.reg[i1]!) }
  -- mccole: /add
  else if op == OP_SUB then
    some { s' with reg := s'.reg.set! i0 (s'.reg[i0]! - s'.reg[i1]!) }
  -- mccole: beq
  else if op == OP_BEQ then
    if s'.reg[i0]! == 0 then some { s' with ip := i1 }
    else some s'
  -- mccole: /beq
  else if op == OP_BNE then
    if s'.reg[i0]! != 0 then some { s' with ip := i1 }
    else some s'
  else if op == OP_PRR then
    some { s' with output := s'.output ++ [s!"{s'.reg[i0]!}"] }
  else if op == OP_PRM then
    some { s' with output := s'.output ++ [s!"{s'.ram[s'.reg[i0]!.toNat]!}"] }
  else
    panic! s!"Unknown op {op}"
-- mccole: /step

-- mccole: run
/-- Run the VM for up to `fuel` steps, returning the final state.
    Halts early when a hlt instruction is encountered.
    The fuel parameter prevents non-termination in tests and proofs. -/
def run (fuel : Nat) (s : VMState) : VMState :=
  match fuel with
  | 0     => s
  | n + 1 =>
    match s.step with
    | none    => s
    | some s' => run n s'
-- mccole: /run

-- mccole: guards
-- A hlt-only program leaves all registers at zero.
#guard
  match VMState.init #[0x000001] with
  | none   => false
  | some s => (run 10 s).reg[0]! == 0

-- ldc R0 42 ; hlt  →  R0 == 42
#guard
  match VMState.init #[0x2A0002, 0x000001] with
  | none   => false
  | some s => (run 10 s).reg[0]! == 42

-- ldc R0 3 ; ldc R1 4 ; add R0 R1 ; hlt  →  R0 == 7
#guard
  match VMState.init #[0x030002, 0x040102, 0x010006, 0x000001] with
  | none   => false
  | some s => (run 10 s).reg[0]! == 7
-- mccole: /guards
