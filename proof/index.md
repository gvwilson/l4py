# Proofs

<div class="callout" markdown="1">

-   Express facts as types and proofs as values using `theorem` and `Prop`
-   Prove equalities and arithmetic facts with `rfl`, `omega`, and `simp`
-   Use `decide` to check concrete decidable propositions at compile time
-   Structure multi-step proofs with `have`, `calc`, and `induction`

</div>

-   Lean is not just a programming language: it is a proof assistant
-   The same type system that checks your data shapes can check mathematical facts

## Propositions are Types

[%inc prop_as_type.lean %]
[%inc prop_as_type.out %]

-   A [%g proposition "proposition" %] is a claim that may be true or false
-   In Lean, propositions are types: `1 + 1 = 2` has type `Prop`
-   `Prop` is the type of all logical claims
    -   Like Python's `bool` but checked by the compiler, not at runtime
-   `True` and `False` are also `Prop` values in the prelude

## Proofs are Values

[%inc rfl_proof.lean %]
[%inc rfl_proof.out %]

-   A [%g proof_term "proof term" %] is a value whose type is a proposition
-   `theorem` is like `def` but the value being defined is a proof
    -   `theorem onePlusOne : 1 + 1 = 2` says "define a proof that `1 + 1 = 2`"
-   `by rfl` is a [%g tactic "tactic" %]: a command that constructs a proof automatically
    -   `rfl` stands for "reflexivity": both sides reduce to the same value
-   `#check @onePlusOne` shows the type of the proof (the proposition itself)
    -   In Lean, some arguments are *implicit*: the type-checker infers them automatically
        rather than requiring the caller to supply them
    -   `@` makes all implicit arguments explicit so `#check` shows the full type signature
    -   For `onePlusOne`, which has no implicit arguments, the output is the same either way
    -   This is like checking the type of a function with `#check`

## When `rfl` Fails

[%inc rfl_fails_err.lean %]
[%inc rfl_fails_err.out %]

-   `rfl` only works when both sides reduce to the same value by computation
-   `1 + 1 = 3` is false, so `rfl` fails with a type mismatch error
    -   The error shows what `rfl` proved (`2 = 2`) vs. what was needed (`1 + 1 = 3`)
-   That's a reasonable error message for once

## The `omega` Tactic

[%inc omega_proof.lean %]
[%inc omega_proof.out %]

-   `omega` is a decision procedure for linear arithmetic over `Nat` and `Int`
    -   It can prove any true fact that involves only `+`, `-`, comparisons, and constants
    -   Named after the [%g omega_test "Omega test" %] from the 1990s
-   Works with universally quantified statements: `(a b : Nat)` means "for all `a` and `b`"
    -   Like Python's `def` parameters, but the function returns a proof, not a value
-   `¬(n < 0)` is the notation for "not `n < 0`" (type `\neg`)
    -   Lean rejects false arithmetic claims even if you ask nicely
-   `rfl`, `omega`, `simp`, `decide`, and `induction` are built into Lean 4: no import needed
    -   `ring`, `linarith`, and `norm_num` require `import Mathlib.Tactic`

## The `simp` Tactic

[%inc simp_proof.lean %]
[%inc simp_proof.out %]

-   `simp` is a simplification tactic: it rewrites the goal using known [%g lemma "lemmas" %]
-   Knows basic list facts: empty list append, list length from literals
-   If `simp` leaves subgoals unsolved, combine it with `omega`: `simp; omega`
-   `simp` is powerful but opaque: you don't always see which rules it used
    -   For teaching purposes, prefer `omega` or `rfl` when they work

## The `decide` Tactic

[%inc decide_proof.lean %]
[%inc decide_proof.out %]

-   `decide` works for propositions that have a decidable algorithm
    -   List membership, modular arithmetic, boolean comparisons
-   Only works for concrete values, not for universally quantified statements
    -   `3 ∈ [1, 2, 3, 4]` is decidable; `∀ n, n ∈ ns` is not
    -   `∀ n, n ∈ ns` means "every natural number is in `ns`", which is always false for a finite list
    -   More importantly, checking it would require testing infinitely many values of `n`;
        `decide` needs a finite computation, so there is no way to enumerate all `Nat` values
-   If `decide` times out, the proposition is probably too large to enumerate

## Using `have`

[%inc have_steps.lean %]
[%inc have_steps.out %]

-   `have h : P := by tactic` introduces an intermediate step named `h`
    -   Like a `let` binding but for propositions instead of values
    -   Once proved, `h` can be used as a hypothesis in the remaining proof
-   Breaking a proof into named steps makes it easier to read and debug
    -   Like decomposing a complex function into helper functions
-   `omega` at the end closes the goal using all available hypotheses
    -   After the two `have` steps, the proof state contains `h1 : 1 + 2 = 3`,
        `h2 : 3 + 3 = 6`, and the original goal `1 + 2 + 3 = 6`
    -   `omega` treats all of these as a system of arithmetic constraints:
        substituting `h1` into the goal gives `3 + 3 = 6`, which is exactly `h2`

## Hypotheses in Theorems

[%inc hypotheses.lean %]
[%inc hypotheses.out %]

-   A theorem can take propositions as parameters: `(ha : 0 < a)`
    -   These are hypotheses: facts the caller must supply
-   The source uses named-parameter syntax `(ha : 0 < a)`, but the output of
    `#check @positiveSum` renders each hypothesis as `→`:
    `∀ (a b : ℤ), 0 < a → 0 < b → 0 < a + b`
    -   This is why `A → B` in Lean means "given a proof of A, produce a proof of B"
    -   Function arrows and logical implication are the same thing in Lean
    -   Calling `positiveSum` with two integers and two proofs returns a proof of the conclusion

## `calc` Chains

[%inc calc_proof.lean %]
[%inc calc_proof.out %]

-   `calc` is equational reasoning: a chain of steps where each links to the last
    -   `_` on the left of each step refers to the right-hand side of the previous step
    -   Each step ends with `:= by tactic`
-   Like a chain of `assert a == b; assert b == c` statements in Python
    -   But the compiler verifies that each link is correct
-   Use `calc` when you need different tactics for different steps, or when intermediate
    steps make the reasoning explicit
-   In `sixViaTwo`: `rfl` cannot prove `2 + 4 = 4 + 2` because `rfl` only succeeds when
    both sides reduce to the same value by computation — Lean evaluates `2 + 4` to `6`
    directly, but does not reorder addends, so `2 + 4` and `4 + 2` are not definitionally
    equal even though they name the same number
    -   `omega` handles the reordering; then `4 + 2 = 6` is definitionally true, so `rfl` closes it
-   `boundsCheck` shows a three-step chain mixing `=` and `≤`:
    rewrite `n + n` as `2 * n`, apply the hypothesis `n ≤ 5` to bound it, then compute `2 * 5`

## Induction

[%inc induction_proof.lean %]
[%inc induction_proof.out %]

-   In Lean, `Nat` is defined inductively: every natural number is either `zero` (0) or
    `Nat.succ n` (the successor of `n`, i.e., `n + 1`)
    -   `2` is `Nat.succ (Nat.succ Nat.zero)`; `3` is one more `succ` on top of that
    -   This mirrors mathematical induction: to prove `P n` for all `n`, prove `P 0` (base case)
        and prove that `P n` implies `P (n + 1)` (step case)
-   `induction n with` splits into cases matching the `inductive` definition of `Nat`
    -   `zero` case: prove the base claim
    -   `succ n ih` case: prove the step, using induction hypothesis `ih`
-   This is why the keyword is `inductive`: you can reason about types by induction
    -   The same principle that lets you recurse over lists works for proofs
-   `omega` in the `succ` case closes the goal using the induction hypothesis from context
    -   `ih : 0 + n = n` is a linear arithmetic fact; `omega` applies it automatically
    -   "Linear" means no variable is multiplied by another variable; the expression involves
        only addition, subtraction, and constants, which `omega` is designed to handle

## Anonymous Proofs

[%inc example_proof.lean %]
[%inc example_proof.out %]

-   `example` is an anonymous theorem: like `theorem` but with no name
    -   Useful for quick checks without cluttering the namespace
    -   Unlike `#guard`, which checks a value at runtime, `example` checks a type
-   Multiple `example` statements don't conflict even if they prove the same thing
    -   Named theorems like `theorem foo : ...` go into the namespace; two theorems with the
        same name produce a duplicate-definition error
    -   `example` has no name, so it never enters the namespace and cannot conflict
    -   Use them freely for exploration

## The `ring` Tactic

[%inc ring_proof.lean %]
[%inc ring_proof.out %]

-   A [%g ring "ring" %] is an algebraic structure with addition and multiplication that obeys
    familiar rules: commutativity, associativity, distributivity, and identity elements (0 and 1)
    -   Integers, natural numbers, and polynomials are all rings
-   `ring` proves identities in commutative rings:
    expressions involving `+`, `*`, `-`, and numeric literals
    -   `omega` handles linear arithmetic; `ring` handles polynomial algebra
    -   Not a Lean 4 built-in: requires `import Mathlib.Tactic`
-   `mulComm` shows multiplication commutativity
    -   `omega` cannot prove this because it involves variable * variable
-   `squareSum` expands `(a + b) * (a + b)` symbolically
    -   Like calling `expand()` in a [%g computer_algebra_system "computer algebra system" %]:
        the system rewrites `(a + b)^2` into `a^2 + 2ab + b^2` symbolically
-   The boundary: use `omega` for anything linear (no variable × variable); use `ring` for polynomials

## Why This Matters

[%inc check_proof.lean %]

-   Lean's proof tactics can verify invariants at compile time, catching bugs before they reach runtime
-   `omega` proves that arithmetic stays within safe bounds given input constraints
    -   `safeByteAdd` guarantees that adding two sub-128 values never overflows a byte:
        this is a statement the compiler checks, not a runtime assertion that can be skipped
    -   Any caller that passes values outside the stated bounds will not type-check
-   `decide` verifies that named constants match their intended values
    -   A mismatch between `0xFF` and `255` becomes a compile-time error rather than a
        latent bug discovered during a code review or test failure
-   `decide` also checks properties of small configuration tables
    -   If a new status code is added to `successCodes` without updating the count,
        `fourSuccessCodes` fails at build time rather than silently at runtime

<div class="exercise" markdown="1">

## Exercises

### Fix: False Equality

[%inc ex_bug_rfl.lean %]

<details markdown="1"><summary>hint</summary>

-   `2 + 2 = 5` is false; no tactic can prove it
-   Change the right-hand side to the correct value: `4`

</details>

### Fix: False Arithmetic Claim

[%inc ex_bug_omega.lean %]

<details markdown="1"><summary>hint</summary>

-   `n + 1 < n` is false for every natural number: `omega` correctly rejects it
-   Change the claim to something true, like `n < n + 1`

</details>

### Fix: Wrong List Length

[%inc ex_bug_simp.lean %]

<details markdown="1"><summary>hint</summary>

-   `[1, 2, 3]` has length `3`, not `4`
-   Change the expected length to `3` and `simp` will succeed

</details>

### Fix: Element Not in List

[%inc ex_bug_decide.lean %]

<details markdown="1"><summary>hint</summary>

-   `5` is not in `[1, 2, 3]`; `decide` will reject a false membership claim
-   Either add `5` to the list, or change the element to one that is already in the list

</details>

### Fix: Wrong Intermediate Step

[%inc ex_bug_have.lean %]

<details markdown="1"><summary>hint</summary>

-   The `have` step claims `10 + 20 = 31`, which is false
-   `rfl` will reject it — fix the claim to `10 + 20 = 30`
-   Once the intermediate step is correct, `omega` can close the goal

</details>

### Fix: False Arithmetic in Induction Exercise

[%inc ex_bug_induction.lean %]

<details markdown="1"><summary>hint</summary>

-   `n + 1 > n + 1` says "strictly greater than itself", which is never true
-   Change the claim to `n + 1 > n`, which `omega` can prove directly

</details>

### Write: Commutativity of Addition

[%inc ex_add_comm.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with `omega`
-   `omega` handles commutativity of addition over natural numbers directly

</details>

### Write: Double Equals Twice

[%inc ex_double_eq.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with `omega`
-   `n + n = 2 * n` is a linear arithmetic fact; `omega` handles it

</details>

### Write: Modular Arithmetic by `decide`

[%inc ex_decide_mod.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with `decide`
-   `17 % 5 = 2` is a concrete numerical fact; `decide` verifies it by computation

</details>

### Write: Empty List Append

[%inc ex_simp_nil.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with `simp`
-   `simp` knows that `[] ++ xs = xs` and applies it automatically

</details>

### Write: Two-Step `calc` Proof

[%inc ex_calc_chain.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with a `calc` block
-   Step 1: `3 + 4 = 4 + 3 := by omega`
-   Step 2: `_ = 7 := by rfl`

</details>

### Write: Zero Is a Lower Bound

[%inc ex_named_theorem.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `sorry` with `omega`
-   `0 ≤ n` for `Nat` is always true because `Nat` cannot be negative

</details>

</div>
