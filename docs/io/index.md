# I/O and Monads

-   Every program eventually has to talk to the world

## Hello World

[%inc hello_world.lean %]
[%inc hello_world.out %]

-   `main` is the entry point of every Lean program
    -   Like Python's `if __name__ == "__main__":` block, but official
-   `IO Unit` is the return type: `IO` means "does input/output", `Unit` means "no useful return value"
    -   Like Python's `None`: the side effects are the point
-   `IO.println` prints a string followed by a newline
-   `#eval main` runs the action during compilation so we can see the output

## Doing More Than One Thing

[%inc do_notation.lean %]
[%inc do_notation.out %]

-   `do` groups a sequence of IO actions into one
    -   Like Python's function body: statements run top to bottom
-   Without `do`, you can only write one IO action per function body
-   Each line in a `do` block runs in order and the result is discarded
    -   Unless you capture it — more on that shortly

## Pure Values Inside `do`

[%inc do_let.lean %]
[%inc do_let.out %]

-   `let x := expr` binds a *pure* (non-IO) value inside a `do` block
    -   Like Python's `x = expr` inside an async function
-   `greet` is a plain function that returns a `String` — no IO
-   You can call pure functions freely inside `do`; only the final `IO.println` does I/O

## Functions That Return IO Actions

[%inc io_functions.lean %]
[%inc io_functions.out %]

-   A function can return an `IO Unit` — a reusable IO action
    -   Like Python's `async def`: calling it gives you something you still have to run
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
-   `let msg ← makeGreeting` runs the action and binds the resulting `String` to `msg`
-   Two binding forms to remember:
    -   `let x := expr` — pure expression, no IO
    -   `let x ← action` — IO action, captures its result

## What Is IO? (And What Is a Monad?)

-   In Python, any function can print, read a file, or open a socket — there is no way to tell from the type
-   Lean keeps track: a function that does I/O has `IO` in its return type
    -   `String` means "a string, computed purely"
    -   `IO String` means "an action that, when run, produces a string"
-   `do` and `←` let you chain IO actions in sequence — this pattern has a formal name: a [%g monad "monad" %]
-   You do not need to understand the theory to use monads in Lean
    -   The practical rules are:
        -   Use `do` to sequence actions
        -   Use `let x ← action` to capture an IO result
        -   Use `let x := expr` for pure computation
        -   Use `return expr` to produce an IO result from a pure value
-   The benefit: the compiler enforces that IO only happens where you say it does
    -   Pure functions are guaranteed not to have side effects
    -   You can test and reason about them without worrying about hidden state

## Pure Functions with IO

[%inc pure_and_io.lean %]
[%inc pure_and_io.out %]

-   `square` is a pure function: no `IO` in its type, no side effects
-   Call it inside `do` with `let result := square 7` — plain `let`, not `←`
-   Or use it inline directly inside string interpolation
-   The compiler will reject `let result ← square 7` because `square` does not return an `IO`

## Reading Input

[%inc read_input.lean %]
[%inc read_input.out %]

-   `IO.getStdin` returns an `IO.FS.Stream` connected to standard input
-   `stdin.getLine` reads one line and returns it as an `IO String`
-   Both require `←` because they are IO actions that produce values
-   The output above shows an empty name because no input was given when regenerating
    -   In an interactive terminal, type a name and press Enter

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing `do`

[%inc ex_bug_no_do.lean %]
[%inc ex_bug_no_do.out %]

<details markdown="1"><summary>hint</summary>

-   Without `do`, Lean treats the body as a single expression
-   The second `IO.println` looks like an argument to the first
-   Add `do` after `:=` to sequence the two actions

</details>

### Fix: Wrong Binding Arrow

[%inc ex_bug_let_bind.lean %]
[%inc ex_bug_let_bind.out %]

<details markdown="1"><summary>hint</summary>

-   `makeMsg` returns `IO String`, not `String`
-   `let msg := makeMsg` stores the IO action itself — never runs it
-   Change `:=` to `←` so Lean runs the action and gives you the `String`

</details>

### Fix: Missing `return`

[%inc ex_bug_return.lean %]
[%inc ex_bug_return.out %]

<details markdown="1"><summary>hint</summary>

-   The function body is `IO String` but `msg` has type `String`
-   Lean needs `return msg` to lift the pure value into `IO`
-   Replace the bare `msg` with `return msg`

</details>

### Fix: Wrong Return Type

[%inc ex_bug_return_type.lean %]
[%inc ex_bug_return_type.out %]

<details markdown="1"><summary>hint</summary>

-   `announce` prints something and returns nothing useful
-   Its return type should be `IO Unit`, not `IO String`
-   Fix the type annotation on line 2

</details>

### Fix: Arrow on a Pure Expression

[%inc ex_bug_arrow.lean %]
[%inc ex_bug_arrow.out %]

<details markdown="1"><summary>hint</summary>

-   `double 5` is a pure function call — it returns `Int`, not `IO Int`
-   `←` is for IO actions; `double 5` is not one
-   Change `let result ← double 5` to `let result := double 5`

</details>

### Fix: Silently Discarded IO Action

[%inc ex_bug_discard.lean %]
[%inc ex_bug_discard.out %]

<details markdown="1"><summary>hint</summary>

-   `let _ := IO.println "Step 2: done"` stores the IO action as a value — it never runs
-   This is the opposite mistake from using `←` on a pure expression
-   Remove the `let _ :=` so the action is a plain statement in the `do` block

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

-   Change `_name` to `name` so the binding is used
-   Replace `"Hello, stranger!"` with `s!"Hello, {name}!"`
-   In an interactive terminal the program will greet whoever types their name

</details>

</div>
