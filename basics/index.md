# Basics

<div class="callout" markdown="1">

-   Write and run simple Lean programs using `#eval` and `def`
-   Work with basic types: `Int`, `Float`, `String`, and `List`
-   Define functions, use pattern matching with `match`, and recurse over lists
-   Handle missing values with `Option` and group related data with `structure`

</div>

-   We have to start somewhere

## Add Numbers

[%inc add_numbers.lean %]
[%inc add_numbers.out %]

-   Lean is a compiled language, so it doesn't have a [%g repl "REPL" %]
-   `#eval` means "evaluate this while compiling"`
-   Run with `lean add_numbers.lean`

## Defining Values

[%inc define_values.lean %]
[%inc define_values.out %]

-   `def` introduces a definition
-   Type specified after a colon
    -   `Int` is integer
-   Assignment uses `:=`

## Strict Typing

[%inc strict_values_err.lean %]
[%inc strict_values_err.out %]

-   Python won't let you do this either
-   But Lean's type system is more powerful and its checking is stricter

## Guards

[%inc guards.lean %]

-   `#guard` introduces code that is checked during compilation
-   Versus Python's `assert`, which is checked as the program runs

## Formatting Strings

[%inc format_strings.lean %]
[%inc format_strings.out %]

-   Use `s!"…"` to interpolate values in strings
    -   Like Python's f-strings

## Lists

[%inc simple_lists.lean %]
[%inc simple_lists.out %]

-   Type of list elements must be declared, and elements must all have the same type
    -   [Next lesson](@/types/) shows how to handle mixed types
-   Index from 0
-   Use `List.length` to get number of elements
    -   Just like `String.length` earlier

## Defining Simple Functions

[%inc simple_functions_0.lean %]
[%inc simple_functions_0.out %]

[%inc simple_functions_1.lean %]
[%inc simple_functions_1.out %]

[%inc simple_functions_2.lean %]
[%inc simple_functions_2.out %]

-   Result of a function is the value of its last expression
    -   So no need for `return`
-   Note that there *aren't* parentheses in `double 3.0`

## What's Actually Happening

[%inc func_partial.lean %]
[%inc func_partial.out %]

-   Every function actually takes only one argument
-   `func a b` defines a function that takes one argument…
-   …and returns a function that takes one argument
-   This is called [%g currying "currying" %]
    -   Named after the mathematician Haskell Curry
    -   The inspiration for Python's `functools.partial`

## Conditionals

[%inc conditional.lean %]
[%inc conditional.out %]

-   `if`/`else if`/`else` is an expression returning a value
-   This doesn't work because the function isn't guaranteed to return a string

[%inc conditional_incomplete_err.lean %]
[%inc conditional_incomplete_err.out %]

-   This doesn't work because the types are inconsistent

[%inc conditional_inconsistent_err.lean %]
[%inc conditional_inconsistent_err.out %]

-   That's a hell of an error message…

## Another Way to Do It

[%inc match.lean %]
[%inc match.out %]

-   Use `match…with` for pattern matching
-   Each alternative uses `|` and `=>`
-   Use `_` as a catch-all

## Recursion

[%inc sum_list.lean %]
[%inc sum_list.out %]

-   Use `::` to get the head and tail of a list
    -   Head is one element
    -   Tail is a list
-   As with conditional, must handle all alternatives
-   Lean checks that you done this have during compilation

## Map, Filter, and Fold

[%inc map_filter_fold.lean %]
[%inc map_filter_fold.out %]

-   Some patterns are so common that they're supported directly
-   `fun args => expr` is used for short anonymous functions like Python's `lambda`
-   `map` and `filter` do what their names suggest
-   `foldl` is "fold left" and *must* be given an initial value

## Local Definitions

[%inc let_binding.lean %]
[%inc let_binding.out %]

-   Use `let` to define local values
-   `let` names are only visible within their enclosing expression

## Tuples

[%inc simple_tuples.lean %]
[%inc simple_tuples.out %]

-   `×` separates the types of tuple elements (type `\times` in the editor)
-   Use `.1` and `.2` to access elements (no, not `.0`)
-   Use `let (x, y) := p` to extract both elements at once

## Missing Values

[%inc option_type.lean %]
[%inc option_type.out %]

-   Lean uses `Option` instead of `None`
-   A function that might not return a value has return type `Option SomeType`
-   `Option.some value` wraps a value; `Option.none` signals absence
-   The compiler forces you to handle both cases
    -   Unlike Python, where forgetting to check for `None` is a runtime error

## Structures

[%inc simple_struct.lean %]
[%inc simple_struct.out %]

-   `structure` groups related values under one name
    -   Like a Python data class or named tuple
-   Access fields with `.fieldName`
-   Create a value by listing field names with `:=` inside `{}`

## Checking and Updating

[%inc check_update.lean %]
[%inc check_update.out %]

-   `#check` checks the type of an expression without evaluating it
-   `Nat` is a natural (non-negative) number

## Type Inference

[%inc type_inference.lean %]
[%inc type_inference.out %]

-   Lean can often figure out types
-   A string literal is a `String`, a whole number is usually an `Int`
-   Return types of functions can often be inferred from the body
-   You can always add type annotations for clarity, but don't have to

## Idiomatic Lean

[%inc idiomatic.lean %]
[%inc idiomatic.out %]

-   Use `·` (a centered dot) to match parameters
    -   Which is a horrible usability decision
-   Type `\cdot` in the editor and `\gt` to get `≥`
-   If there are multiple parameters, each `·` matches the next one
    -   Which is an even worse usability decision, but we're stuck with it

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing Else Branch

[%inc ex_bug_conditional.lean %]

<details markdown="1"><summary>hint</summary>

-   The `describe` function doesn't handle the case when `n` is zero
-   The compiler will reject this: add the missing `else` branch

</details>

### Fix: Non-Exhaustive Match

[%inc ex_bug_match.lean %]

<details markdown="1"><summary>hint</summary>

-   `firstOrZero` only handles the case where the list has at least one element
-   Add a branch for the empty list that returns `0`

</details>

### Fix: Unhandled Option

[%inc ex_bug_option.lean %]

<details markdown="1"><summary>hint</summary>

-   `getValue` only handles `Option.some` but not `Option.none`
-   Add a branch that returns `"missing"` when the option is `none`

</details>

### Fix: Wrong Base Case

[%inc ex_bug_recursion.lean %]

<details markdown="1"><summary>hint</summary>

-   Multiplying by zero gives zero, so the base case `[] => 0` breaks everything
-   What should the product of an empty list be? (Hint: think about `1 * 2 * 3`)

</details>

### Fix: Wrong Return Type

[%inc ex_bug_types.lean %]

<details markdown="1"><summary>hint</summary>

-   The function body returns an `Int` but the type annotation says `String`
-   Fix the type annotation to match what the body actually returns

</details>

### Write: Double a Number

[%inc ex_double.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `0.0` with an expression that doubles `x`
-   The `#guard` statements will tell you if your solution is correct

</details>

### Write: Make a Greeting

[%inc ex_greeting.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `""` with a string that includes the person's name
-   Use `s!"…"` interpolation like the examples earlier in the lesson

</details>

### Write: List Length

[%inc ex_list_length.lean %]

<details markdown="1"><summary>hint</summary>

-   Write a recursive function that counts the elements in a list
-   Do not use `List.length` — implement it yourself with `match` and `::`

</details>

### Write: Swap a Tuple

[%inc ex_swap_tuple.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `("", 0)` with the elements of `p` in reverse order
-   Use `.1` and `.2` to access the fields of the tuple

</details>

### Write: Update a Structure

[%inc ex_update_struct.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `p` with a new `Point` that has `x` incremented by `1.0`
-   Use the `{ old with field := newVal }` syntax shown in the structures section

</details>

</div>
