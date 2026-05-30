# A Virtual Machine

<div class="callout" markdown="1">

-   Every computer has a processor with a particular instruction set, some registers, and memory
-   Instructions are just numbers but can be written as human-readable assembly code
-   Each instruction packs an op code and up to two operands into a single word using bitwise shifts
-   A processor usually executes instructions in order but can jump to another address
    based on a conditional test
-   An assembler translates text mnemonics into packed instruction words and resolves label addresses

</div>

Our virtual machine (VM) simulates a small computer with three parts:

1.  An instruction pointer (IP) that holds the address of the next instruction to execute,
    initialized to 0 at startup.

2.  Four general-purpose registers R0–R3 that instructions read and write directly.
    All arithmetic goes through registers; there are no memory-to-memory operations.

3.  256 words of RAM that holds both the program and its data.
    Addresses are one byte wide, which is why 256 words is a natural size.

## Architecture Constants

[%inc architecture.lean mark=constants %]

-   `NUM_REG` and `RAM_LEN` are `Nat` because they are used as array sizes
-   `OP_MASK` and `OP_SHIFT` are `UInt32` because they are used in bitwise operations on instruction words
-   Collecting all of a system's defining constants in one file makes them easy to find
    and guarantees that every module uses the same values

[%inc architecture.lean mark=opcodes %]

-   Each instruction fits in one byte, so op codes run from `0x1` to `0xB`
-   Operand formats: `--` means no operands, `r-` means one register, `rr` means two registers,
    `rv` means a register and a literal value

## VM State

[%inc machine.lean mark=state %]

-   `ip` is a `Nat` because it indexes into `ram`
-   `reg` and `ram` are `Array UInt32`
    -   Fixed-width unsigned integers match real hardware
-   `output` collects lines printed by `prr` and `prm`,
     keeping the VM pure so its behavior can be checked with `#guard` without any `IO`

[%inc machine.lean mark=init %]

-   `Array.range RAM_LEN` produces `#[0, 1, …, 255]`
    -   Mapping over it fills RAM with program words followed by zeros
-   `program.getD i 0` returns `program[i]` if in bounds, otherwise the default `0`

## Fetching Instructions

-   Each instruction is packed into one 32-bit word
    -   The op code occupies bits 7–0
    -   The first operand occupies bits 15–8
    -   The second operand occupies bits 23–16

[%inc machine.lean mark=fetch %]

-   `&&&` masks off all bits above the lowest byte, isolating one field
-   `>>>` shifts the word right so the target byte becomes the low byte
-   Unpacking is the reverse of the packing done by the assembler's `combine` function
-   Two operands are always decoded regardless of whether the instruction uses them,
    matching how most real hardware works

## Executing Instructions

[%inc machine.lean mark=step %]

-   `s.fetch` returns the decoded triple and the state with IP already advanced
-   `arg0.toNat` converts to `Nat` for use as an array index
-   Returning `Option VMState` (rather than using `IO`) keeps `step` pure and testable

## Example: Store Register Value in RAM

-   `str` stores register `arg0` into the RAM address held in register `arg1`

[%inc machine.lean mark=str %]

## Example: Add Two Registers

-   `add` writes the sum of two registers back into the first

[%inc machine.lean mark=add %]

## Example: Jump If

-   `beq` jumps to a literal address if a register's value is zero
-   This is how loops end

[%inc machine.lean mark=beq %]

## Running a Program

[%inc machine.lean mark=run %]

-   Structural recursion on `fuel` guarantees termination, which Lean requires for `#guard`
-   `fuel = 0` is the out-of-fuel case
    -   Returning `s` rather than panicking
     lets tests distinguish "halted normally" from "ran out of steps" by inspecting the IP
-   `partial def` would also work for a non-terminating VM, but `#guard` cannot reduce it

[%inc machine.lean mark=guards %]

## Assembly Code

-   Writing hexadecimal instruction words by hand is error-prone
-   An assembler translates a readable text format into packed instruction words
-   Each mnemonic maps to an op code and a format string that controls how operands are parsed:

[%inc assembler.lean mark=ops %]

### Parsing Helpers

[%inc assembler.lean mark=helpers %]

-   `parseReg` strips the leading `R` and checks that the index is within `NUM_REG`
-   `parseVal` recognises `@label` references by the leading `@`
    -   Otherwise it parses a decimal integer
-   `combine` shifts each value eight bits left and ORs in the next
    -   The first argument in the list ends up in the highest byte

### Finding Labels

[%inc assembler.lean mark=labels %]

-   Labels end with `:` and are not emitted as instruction words
-   `loc` counts only non-label lines, giving each label the address of the next real instruction
-   The result is a `List (String × Nat)` used by `parseVal` to resolve `@label` operands

### Compiling One Line

[%inc assembler.lean mark=compile %]

-   Pattern-matching on `info.fmt` selects the right operand count and order
-   `"rr"` passes `[r1, r0, code]` to `combine` so `r1` lands in the high byte
    -   Matches how `fetch` extracts `arg1` from bits 23–16
-   Returning `none` on any malformed token propagates cleanly through `assemble` via the `Option` monad

### Assembling a Program

[%inc assembler.lean mark=assemble %]

-   `do` notation for `Option` lets `←` short-circuit on the first `none`
-   `List.mapM` sequences `compileLine` over every instruction line,
    collecting results into `Option (List UInt32)`
-   `words.toArray` converts the result to an `Array` matching `VMState.ram`'s type

[%inc assembler.lean mark=asm-guards %]

## End-to-End Example

-   This program counts from 0 to 2, printing each value:

```
ldc R0 0      -- R0 = loop index
ldc R1 3      -- R1 = loop limit
loop:
prr R0        -- print index
ldc R2 1      -- R2 = 1 (needed because add is register-to-register)
add R0 R2     -- R0 += 1
cpy R2 R1     -- R2 = limit (sub overwrites its first operand)
sub R2 R0     -- R2 = limit - index
bne R2 @loop  -- repeat while R2 != 0
hlt
```

-   The assembler resolves `@loop` to address 2
    -   The address of `prr R0` after labels are removed
-   `run 100` provides enough fuel for nine iterations of the inner logic:

[%inc assembler.lean mark=integration %]

<div class="exercise" markdown="1">

## Exercises

### Trace by Hand (10 min)

Write out the values of R0, R1, and R2 after each instruction in the first two
iterations of the count-up loop above.  At which step does `bne` decide not to jump?

### Swap Two Registers (20 min)

Write an assembly program that swaps the values of R1 and R2 without changing R0 or R3.
You will need a temporary register.  Encode the program as a `#guard` that checks the
final register state.

### Increment and Decrement (20 min)

Add `OP_INC` and `OP_DEC` constants to `architecture.lean` with codes `0xC` and `0xD`.
Add matching branches to `VMState.step` in `machine.lean` (format `"r-"`, one register).
Add entries to `OPS` in `assembler.lean`.  Rewrite the count-up example using `inc`
instead of `ldc R2 1; add R0 R2`.

### Disassembler (30 min)

Write a function `disassemble (prog : Array UInt32) : List String` that turns each
packed word back into a mnemonic string such as `"ldc R0 42"`.
Since labels are not stored in the machine code, generate synthetic names `L000`, `L001`,
… for any address that appears as the target of a `beq` or `bne` instruction.

### Store and Load an Array (30 min)

Write an assembly program (as a Lean string list) that stores the values 0–3 into
consecutive memory locations starting at address 20, then reads them back and prints each one.
Verify with a `#guard` that `output == ["0", "1", "2", "3"]`.

### Call and Return (45 min)

Add a stack pointer register SP initialized to address 255.
Add `psh` (push: write `reg[arg0]` to `ram[SP]` then decrement SP) and
`pop` (increment SP then read `ram[SP]` into `reg[arg0]`).
Using these instructions, write a subroutine that doubles the value in R0,
called twice with different inputs, and verify with `#guard`.

</div>
