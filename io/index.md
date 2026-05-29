# I/O and Monads

<div class="callout" markdown="1">

-   Understand the `IO` type and how Lean separates pure computation from side effects
-   Sequence IO actions with `do` blocks and `←` (left arrow)
-   Capture results from IO actions and chain them into larger programs
-   Read from standard input and print to standard output

</div>

-   Every program eventually has to talk to the world

## What Is IO? (And What Is a Monad?)

-   A function that does I/O has `IO` in its return type
    -   `String` means "a string, computed purely"
    -   `IO String` means "an action that, when run, produces a string"
    -   This pattern's formal name is a [%g monad "monad" %]
-   The compiler enforces that IO only happens where you say it does
    -   Pure functions are guaranteed not to have side effects
    -   You can test and reason about them without worrying about hidden state
-   This is like Python's `async def`: an async function must return an `Awaitable`
    -   You cannot accidentally run an async function from sync code
    -   Lean's `IO` type is the same idea: the compiler prevents IO from leaking into pure functions
-   Separately, `do` and `←` (left arrow) are how you *sequence* effectful actions
    -   This is the monad part: chaining steps where each depends on the last
    -   Like `await` lets you write sequential-looking code asynchronously, `←` does the same for IO
-   You do not need to understand the theory to use monads in Lean
    -   (DEBT) We will revisit the theory once we are comfortable doing I/O

## Hello World

[%inc hello_world.lean %]
[%inc hello_world.out %]

-   `main` is the entry point for Lean programs
    -   Like Python's `if __name__ == "__main__":` block
-   `IO Unit` is the return type: `IO` means "does input/output", `Unit` means "no useful return value"
    -   `Unit` is like Python's `None`: the side effects are the point
-   `IO.println` prints a string followed by a newline
    -   Newline plus indentation isn't required, but it helps
-   `#eval main` runs the action during compilation so we can see the output
-   Lean's pure functions cannot raise exceptions; IO actions can fail at runtime and are caught with `try`/`catch`
    -   Errors in pure code are handled with sum types like `Except`, which we'll cover later in this chapter

## Doing More Than One Thing

[%inc do_notation.lean %]
[%inc do_notation.out %]

-   `do` groups a sequence of IO actions into one
    -   Statements run top to bottom
-   Without `do`, we can only write one IO action per function body
-   Each line in a `do` block runs in order and must return `IO Unit`
    -   Unless we capture it: more on that shortly
-   If your function body is a single IO action, no `do` is needed
-   If you want two or more actions in sequence, wrap them in `do`
-   `;` can be used as an alternative separator inside `do` blocks
    -   E.g., `IO.println "Hi"; IO.println "there"` is equivalent to two lines

## Forgetting `do`

[%inc ex_missing_do.lean %]

-   Forgetting `do` is the most common IO mistake
-   Without `do`, Lean tries to use the second `IO.println` as an argument to the first
    -   That's why the error message mentions "application type mismatch"
-   The fix: add `do` after `:=`

## Pure Values Inside `do`

[%inc do_let.lean %]
[%inc do_let.out %]

-   `let x := expr` binds a *pure* (non-IO) value inside a `do` block
    -   Like Python's `x = expr` inside an async function
-   `greet` is a plain function that returns a `String` (no I/O)
-   You can call pure functions freely inside `do`
    -   Only the final `IO.println` does I/O
-   The compiler will reject `let msg ← greet "Lean"` because `greet` does not return an `IO`
-   `let _ := expr` is the *discard* pattern: it binds a value but throws it away
    -   The underscore means "I don't intend to use this"
    -   It also suppresses the unused-variable warning from the compiler
    -   *Warning:* `let _ := someIOAction` stores the action without running it — use `←` for IO

## Functions That Return IO Actions

[%inc io_functions.lean %]
[%inc io_functions.out %]

-   A function can return an `IO Unit`: a reusable IO action
    -   Like Python's `async def`, calling it gives you something you still have to run
-   `printTwice "echo!"` runs two `IO.println` calls in sequence
-   IO functions compose: `main` calls `printTwice` twice

## Capturing Results from IO

[%inc io_return.lean %]
[%inc io_return.out %]

-   Use `let x ← ioAction` (the left-arrow `←`) to capture the result of an IO action
    -   Like Python's `x = await some_coroutine()`
    -   Type `\leftarrow` in the editor
-   `makeGreeting` has type `IO String`: it is an action that produces a `String`
-   `return expr` wraps a pure value as an IO result
    -   This is *not* the same as Python's `return`, which exits the function immediately
    -   Lean's `return` stays in the `do` block: it just marks a value as an IO result
    -   Yes, this is confusing…
-   `let msg ← makeGreeting` runs the action and binds the resulting `String` to `msg`
-   Two binding forms to remember:
    -   `let x := expr` is a pure expression, no IO
    -   `let x ← action` is an I/O action, captures its result

## Reading Input

[%inc read_input.lean %]
[%inc read_input.out %]

-   `IO.getStdin` returns an `IO.FS.Stream` connected to standard input
-   `stdin.getLine` reads one line and returns it as an `IO String`
-   Both require `←` because they are IO actions that produce values
-   `String.trimAscii` removes leading and trailing whitespace, including the trailing newline
    -   Without `.trimAscii`, `getLine` returns the newline character as part of the string
    -   This would make `s!"Hello, {name}!"` print an unwanted line break
-   The output above shows an empty name because `#eval` runs inside the Lean compiler process
    -   The compiler claims stdin for its own use, so `stdin.getLine` returns an empty string
    -   This is a limitation of `#eval`, not of Lean's IO system
    -   In the next lesson we will compile and run programs as proper executables, where stdin works correctly

## Chaining IO Actions

[%inc chain_io.lean %]
[%inc chain_io.out %]

-   `do` blocks compose naturally: you can chain as many `←` binds as you need
-   Each `←` runs the action and captures its result for the next step
-   Here `getLine` is called twice: once for the first name, once for the last name
    -   Both captures are combined in a single `IO.println`
-   Like writing multiple `await` calls in one `async` function

## For Loops in `do` Blocks

[%inc for_loop.lean %]
[%inc for_loop.out %]

-   `for x in list do` iterates over a list inside a `do` block
    -   Like Python's `for x in list:` but the body is an IO action
-   Each iteration runs in sequence, top to bottom
-   Works with `List`, `Array`, and any type that implements `ForIn`
    -   Including the results of `IO.FS.readDir` (see [archive](@/archive/))
-   The loop is syntactic sugar for recursion — there is no mutable loop variable by default

## Accumulating Results with `for`

[%inc for_accum.lean %]
[%inc for_accum.out %]

-   `let mut count := 0` declares a mutable variable in a `do` block
    -   Only valid inside `do`; pure functions cannot use `mut`
-   `count := count + 1` updates it — without `:=`, the variable is read-only
-   Like Python's `count = 0; for w in words: if ...: count += 1`
-   Lean guarantees `mut` variables don't escape the `do` block
    -   They are not truly mutable memory — the compiler translates them into state-passing

## What `let mut` Really Does

[%inc let_mut_state.lean %]
[%inc let_mut_state.out %]

-   `let mut` is syntactic sugar: the compiler rewrites mutable variables as extra function arguments threaded through each step
    -   The generated code is purely functional; no heap mutation occurs
    -   This is why pure functions can remain efficient even without mutable state: the compiler handles the bookkeeping
-   The pure `foldl` version and the `let mut` loop produce the same result
    -   For straightforward accumulation, the pure form is often shorter
    -   For complex logic with multiple conditions or early exit, `let mut` is usually easier to read
-   Both approaches are O(n) in the list length

## Summary

-   `do` and `←` let you chain IO actions in sequence
-   The practical rules are:
    -   Use `do` to sequence actions
    -   Use `let x ← action` to capture an IO result
    -   Use `let x := expr` for pure computation
    -   Use `return expr` to produce an IO result from a pure value
-   Lean's `IO` is more than just files and sockets
-   It also manages random number generation and any other [%g effectful "effectful" %] computation

## Errors Without Exceptions

[%inc except_pure.lean %]
[%inc except_pure.out %]

-   `Except String Int` is a sum type with two constructors:
    -   `Except.ok n` — success, carrying a value of type `Int`
    -   `Except.error e` — failure, carrying a message of type `String`
-   Like Python's `(value, error)` tuple convention, but the compiler forces you to check both cases
-   `match` on an `Except` is exhaustive: you cannot forget the error case
-   Use `Except` for pure functions that can fail with a reason
    -   Use `Option` when absence is normal and no explanation is needed

## IO Can Fail

[%inc except_io.lean %]
[%inc except_io.out %]

-   `try action catch _ => fallback` catches any IO exception
    -   The `_` discards the exception value — inspect it with `catch e => ...` if needed
-   IO operations like `IO.FS.readFile` throw on failure (file not found, permission denied, etc.)
-   Wrapping in `try`/`catch` converts an exception into a safe `Option` or `Except` value
-   Like Python's `try: ... except OSError: ...` but typed: the return type shows the fallback
-   Pure `Except` (from the previous section) and IO `try`/`catch` are complementary:
    -   Pure functions use `Except` to report errors without side effects
    -   IO functions use `try`/`catch` to handle runtime failures

## Lean's Three Error-Handling Mechanisms

Lean splits failure across three mechanisms where Python uses exceptions for all of them:

| Mechanism | Where | When to use |
|-----------|-------|-------------|
| `Option` | Pure functions | Absence is normal; no explanation needed. E.g., looking up a key that may not exist. |
| `Except e a` | Pure functions | Failure needs a reason. E.g., parsing a string that may be malformed. |
| `try`/`catch` | IO actions | Runtime failure outside your control. E.g., file not found, network error. |

-   `Option` and `Except` appear in function signatures, so the compiler forces callers to handle failure
-   `try`/`catch` is only available in `IO`; you cannot silently ignore an IO exception
-   When migrating from Python: replace `None` returns with `Option`, replace `ValueError`/`KeyError` in pure logic with `Except`, and replace `OSError`/`IOError` with `try`/`catch` around IO actions

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing `do`

[%inc ex_bug_no_do.lean %]

<details markdown="1"><summary>hint</summary>

-   Without `do`, Lean treats the body as a single expression
-   The second `IO.println` looks like an argument to the first

</details>

### Fix: Wrong Left Arrow

[%inc ex_bug_let_bind.lean %]

<details markdown="1"><summary>hint</summary>

-   `makeMsg` returns `IO String`, not `String`
-   `let msg := makeMsg` stores the IO action itself rather than running it

</details>

### Fix: Missing `return`

[%inc ex_bug_return.lean %]

<details markdown="1"><summary>hint</summary>

-   The function body is `IO String` but `msg` has type `String`
-   Lean needs `return msg` to lift the pure value into `IO`

</details>

### Fix: Wrong Return Type

[%inc ex_bug_return_type.lean %]

<details markdown="1"><summary>hint</summary>

-   `announce` prints something and returns nothing useful
-   Its return type should be `IO Unit`, not `IO String`

</details>

### Fix: Arrow on a Pure Expression

[%inc ex_bug_arrow.lean %]

<details markdown="1"><summary>hint</summary>

-   `double 5` is a pure function call: it returns `Int`, not `IO Int`
-   `←` is for IO actions; `double 5` is not one

</details>

### Fix: Silently Discarded IO Action

[%inc ex_bug_discard.lean %]

<details markdown="1"><summary>hint</summary>

-   `let _ := IO.println "Step 2: done"` stores the IO action as a value — it never runs
-   The underscore (`_`) means "I don't intend to use this binding"
-   For an IO action, you want `←` (run it) or plain `IO.println` (no binding at all)

</details>

### Write: Two-Line Greeting

[%inc ex_hello.lean %]

<details markdown="1"><summary>hint</summary>

-   Add a second `IO.println` call inside the `do` block
-   The text should be `"Ready to go!"`
-   Both lines are plain `IO.println` calls with no `←`

</details>

### Write: Print in Uppercase

[%inc ex_shout.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `IO.println msg` with `IO.println msg.toUpper`
-   `String.toUpper` (or `.toUpper`) converts a string to all capitals
-   The body is a single expression, so no `do` needed

</details>

### Write: Build a Message

-   Use `++` to concatenate strings

[%inc ex_build_msg.lean %]

<details markdown="1"><summary>hint</summary>

-   The function should return `"Message: " ++ text`
-   Use `return ("Message: " ++ text)` to lift the pure result into `IO`
-   When you fix it, `main` should print `Message: ready`

</details>

### Write: Use a Pure Function in IO

[%inc ex_pure_io.lean %]

<details markdown="1"><summary>hint</summary>

-   Call `addUp [1, 2, 3, 4, 5]` with `let total := ...` (plain `let`, not `←`)
-   Then use `total` inside `s!"Sum is {total}"` in the `IO.println` call
-   The output should be `Sum is 15`

</details>

### Write: Repeat Three Times

[%inc ex_repeat.lean %]

<details markdown="1"><summary>hint</summary>

-   Add `do` to the body of `repeat3` and call `IO.println msg` three times
-   Each call is a separate line in the `do` block
-   When fixed, `main` should print `again` three times

</details>

### Write: Read and Greet

[%inc ex_read_greet.lean %]

<details markdown="1"><summary>hint</summary>

-   `_name` uses `_` (underscore prefix) to suppress the unused-variable warning
    -   Lean warns you when a variable is bound but never used
    -   Prefixing with `_` tells Lean "I'm keeping this binding but not using it yet"
-   Change `_name` to `name` so the binding is used
-   Replace `"Hello, stranger!"` with `s!"Hello, {name.trimAscii}!"`
    -   `getLine` returns the line *with* the trailing newline
    -   Use `.trimAscii` to remove it before printing

</details>

</div>
