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
-   Lean doesn't have exceptions
    -   Errors are handled with sum types like `Except`, which we'll cover later (DEBT)

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
[%inc ex_missing_do.out %]

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

## Summary

-   `do` and `←` let you chain IO actions in sequence
-   The practical rules are:
    -   Use `do` to sequence actions
    -   Use `let x ← action` to capture an IO result
    -   Use `let x := expr` for pure computation
    -   Use `return expr` to produce an IO result from a pure value
-   Lean's `IO` is more than just files and sockets
-   It also manages random number generation and any other [%g effectful "effectful" %] computation

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing `do`

[%inc ex_bug_no_do.lean %]
[%inc ex_bug_no_do.out %]

<details markdown="1"><summary>hint</summary>

-   Without `do`, Lean treats the body as a single expression
-   The second `IO.println` looks like an argument to the first

</details>

### Fix: Wrong Left Arrow

[%inc ex_bug_let_bind.lean %]
[%inc ex_bug_let_bind.out %]

<details markdown="1"><summary>hint</summary>

-   `makeMsg` returns `IO String`, not `String`
-   `let msg := makeMsg` stores the IO action itself rather than running it

</details>

### Fix: Missing `return`

[%inc ex_bug_return.lean %]
[%inc ex_bug_return.out %]

<details markdown="1"><summary>hint</summary>

-   The function body is `IO String` but `msg` has type `String`
-   Lean needs `return msg` to lift the pure value into `IO`

</details>

### Fix: Wrong Return Type

[%inc ex_bug_return_type.lean %]
[%inc ex_bug_return_type.out %]

<details markdown="1"><summary>hint</summary>

-   `announce` prints something and returns nothing useful
-   Its return type should be `IO Unit`, not `IO String`

</details>

### Fix: Arrow on a Pure Expression

[%inc ex_bug_arrow.lean %]
[%inc ex_bug_arrow.out %]

<details markdown="1"><summary>hint</summary>

-   `double 5` is a pure function call: it returns `Int`, not `IO Int`
-   `←` is for IO actions; `double 5` is not one

</details>

### Fix: Silently Discarded IO Action

[%inc ex_bug_discard.lean %]
[%inc ex_bug_discard.out %]

<details markdown="1"><summary>hint</summary>

-   `let _ := IO.println "Step 2: done"` stores the IO action as a value — it never runs
-   The underscore (`_`) means "I don't intend to use this binding"
-   For an IO action, you want `←` (run it) or plain `IO.println` (no binding at all)

</details>

### Write: Two-Line Greeting

[%inc ex_hello.lean %]
[%inc ex_hello.out %]

<details markdown="1"><summary>hint</summary>

-   Add a second `IO.println` call inside the `do` block
-   The text should be `"Ready to go!"`
-   Both lines are plain `IO.println` calls with no `←`

</details>

### Write: Print in Uppercase

[%inc ex_shout.lean %]
[%inc ex_shout.out %]

<details markdown="1"><summary>hint</summary>

-   Replace `IO.println msg` with `IO.println msg.toUpper`
-   `String.toUpper` (or `.toUpper`) converts a string to all capitals
-   The body is a single expression, so no `do` needed

</details>

### Write: Build a Message

-   Use `++` to concatenate strings

[%inc ex_build_msg.lean %]
[%inc ex_build_msg.out %]

<details markdown="1"><summary>hint</summary>

-   The function should return `"Message: " ++ text`
-   Use `return ("Message: " ++ text)` to lift the pure result into `IO`
-   When you fix it, `main` should print `Message: ready`

</details>

### Write: Use a Pure Function in IO

[%inc ex_pure_io.lean %]
[%inc ex_pure_io.out %]

<details markdown="1"><summary>hint</summary>

-   Call `addUp [1, 2, 3, 4, 5]` with `let total := ...` (plain `let`, not `←`)
-   Then use `total` inside `s!"Sum is {total}"` in the `IO.println` call
-   The output should be `Sum is 15`

</details>

### Write: Repeat Three Times

[%inc ex_repeat.lean %]
[%inc ex_repeat.out %]

<details markdown="1"><summary>hint</summary>

-   Add `do` to the body of `repeat3` and call `IO.println msg` three times
-   Each call is a separate line in the `do` block
-   When fixed, `main` should print `again` three times

</details>

### Write: Read and Greet

[%inc ex_read_greet.lean %]
[%inc ex_read_greet.out %]

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
