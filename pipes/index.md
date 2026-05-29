# Functional Pipelines

<div class="callout" markdown="1">

-   Chain function calls left-to-right with the forward pipeline operator `|>`
-   Compose functions into new functions with `∘`
-   Build data transformation pipelines using filter, map, and fold
-   Import libraries and organize code with namespaces

</div>

-   Functions are the verbs of programming
-   Pipelines let you chain them into readable data flows

## Forward Pipeline

[%inc forward_pipe.lean %]
[%inc forward_pipe.out %]

-   `x |> f` means "apply `f` to `x`"
    -   Like Unix pipes: `echo world | wc` flows data left to right
-   Without `|>`, nested calls read inside-out: `f (g (h x))`
    -   With `|>`, they read left to right: `x |> h |> g |> f`
-   `|>` is just syntactic sugar: `x |> f` is exactly `f x`
    -   But it puts the data first and the transformation second, which is easier to scan
-   Works with any function: named, anonymous, library, your own

## Anonymous Functions in Pipelines

[%inc pipe_anonymous.lean %]
[%inc pipe_anonymous.out %]

-   Anonymous functions work naturally in pipelines
-   The `·` placeholder (from [basics](@/basics/)) makes them compact
-   `List.map` and `List.filter` use the fully-qualified `List.` prefix
    -   We'll explain `List.` vs plain `map` shortly (DEBT)

## Function Composition

[%inc function_composition.lean %]
[%inc function_composition.out %]

-   `∘` (type `\comp`) composes two functions into a new function
    -   `(f ∘ g) x` means "apply `g`, then apply `f`"
-   Like `|>` but without the data: you're building a function, not applying one
-   Composition reads right-to-left: `shout ∘ greet` means "greet then shout"
    -   This matches math notation: `(f ∘ g)(x) = f(g(x))`
-   Use parentheses to compose more than two: `f ∘ (g ∘ h)` or `(f ∘ g) ∘ h`

## Composition vs. Pipeline

[%inc composition_v_pipe.lean %]
[%inc composition_v_pipe.out %]

-   `|>` feeds data through functions: `3 |> addOne |> double`
    -   Use when you have a value
-   `∘` builds a new function from two existing ones: `double ∘ addOne`
    -   Use when you want to name the combined operation and reuse it
-   `x |> f |> g` is equivalent to `(g ∘ f) x`
    -   But `|>` is usually clearer when you have the data in hand

## Point-Free Style

[%inc point_free.lean %]
[%inc point_free.out %]

-   Point-free style omits the argument names entirely
    -   The argument is implicit: "double after adding one"
-   `doubleAfterAdd` names `x` explicitly; `doubleAfterAddPF` never mentions it
    -   Both produce the same result
-   Point-free is concise for simple pipelines
    -   For complex logic, naming the arguments is usually clearer
-   Python equivalent: `compose(double, add_one)` instead of `lambda x: double(add_one(x))`

## Filter-Map-Fold Pipelines

[%inc pipelines.lean %]
[%inc pipelines.out %]

-   Filter-map-fold chains are the bread and butter of functional pipelines
-   Instead of naming intermediate results, thread data through transformations
-   Each `|>` feeds the previous result into the next function
-   Like Python list comprehensions with chained operations
    -   `[x*3 for x in data if x > 2]` is a filter-then-map in one expression
    -   But pipelines separate concerns and can chain more steps

## Pipelines vs. Imperative Loops

[%inc imperative_v_pipeline.lean %]
[%inc imperative_v_pipeline.out %]

-   The recursive version spells out *how*: loop, accumulate, test, branch
-   The pipeline version describes *what*: filter evens, square them, sum
-   Both produce the same result; pipelines are usually easier to read
-   In Python, you'd write a `for` loop with `if` and an accumulator variable
    -   The pipeline is the same idea as `sum(x*x for x in xs if x % 2 == 0)`

## Pipelines with Strings

[%inc pipeline_string.lean %]
[%inc pipeline_string.out %]

-   Pipelines work with any type, not just numbers
-   `String.toUpper` is a function you can pass to `List.map`
-   `String.intercalate` joins list elements with a separator
    -   Like Python's `" | ".join(["HELLO", "WORLD"])`
-   Notice the pipeline uses `fun w => w.length > 4` because we need to name `w`
    -   `(·.length > 4)` is not valid Lean syntax, so we fall back to explicit `fun`

## Importing Libraries

[%inc import_library.lean %]
[%inc import_library.out %]

-   `import ModuleName` brings a library module into scope
    -   Like Python's `import module`
-   The Lean [%g prelude "prelude" %] is always available without imports
    -   It includes `List`, `String`, `Option`, `Nat`, `Int`, and basic operations
-   Everything we've used so far comes from the prelude
-   For more advanced features, you import additional modules
    -   `import Std` gives you the extended standard library
    -   We'll see more import examples in later lessons (DEBT)

## Namespaces

[%inc namespaces.lean %]
[%inc namespaces.out %]

-   `namespace Name … end Name` wraps definitions in a named scope
    -   Like Python modules or C++ namespaces
-   Two namespaces can define the same function name without collision
    -   `Greeting.hello` and `Farewell.hello` are different functions
-   Use `Namespace.name` to refer to a definition from outside
    -   Like Python's `module.function` after `import module`

## Opening Namespaces

[%inc open_namespace.lean %]
[%inc open_namespace.out %]

-   `open NamespaceName` brings all names into the current scope
    -   Like Python's `from module import *`
-   After `open Colors`, you can write `red` instead of `Colors.red`
-   Use sparingly: it can make code harder to understand
    -   Where did `red` come from? You have to scan upward to find the `open`

## Standard Library Examples

[%inc library_examples.lean %]
[%inc library_examples.out %]

-   `List` has many functions beyond `map`, `filter`, and `foldl`
-   `take n` keeps the first `n` elements
-   `drop n` discards the first `n` elements
-   `List.range n` generates `[0, 1, …, n-1]`
    -   Like Python's `range(n)` but returns a list, not an iterator
-   `List.zip` pairs elements from two lists into tuples
    -   Like Python's `zip(list1, list2)`
-   All of these compose naturally in pipelines

## Arrays vs. Lists

[%inc arrays_vs_lists.lean %]
[%inc arrays_vs_lists.out %]

-   Lean has two sequence types with different performance characteristics
-   `List` (e.g. `[1, 2, 3]`) is a singly-linked list
    -   Adding to the front with `::` is O(1)
    -   Pattern matching on head/tail is idiomatic and efficient
    -   `List.length` and indexed access `list[i]!` are O(n)
-   `Array` (e.g. `#[1, 2, 3]`) stores elements contiguously in memory
    -   Indexed access `arr[i]!` is O(1)
    -   Appending is amortized O(1) (like Python's `list.append`)
    -   Cannot be pattern-matched with `::`
-   Python's `list` is closer to Lean's `Array` in performance
    -   If you're porting Python that uses `xs[i]`, use `Array` in Lean
    -   If you're writing idiomatic Lean with `map`/`filter`/`foldl`, `List` is the natural choice
-   Most IO functions (like `IO.FS.readDir`) return `Array`; pipeline functions work on `List`
    -   Convert with `arr.toList` or `lst.toArray` as needed

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing Pipeline Step

[%inc ex_bug_pipe.lean %]

<details markdown="1"><summary>hint</summary>

-   The pipeline doubles every number and sums the result
-   But the instructions say to keep only even results before summing
-   Add `|> List.filter (· % 2 == 0)` between the `map` and the `foldl`

</details>

### Fix: Wrong Composition Order

[%inc ex_bug_composition.lean %]

<details markdown="1"><summary>hint</summary>

-   `addOne ∘ double` means "double first, then add one"
-   The `#guard` expects `wrong 3 == 8`, which is `(3+1)*2 = 8`
-   Swap the functions so `addOne` runs first, then `double`

</details>

### Write: Word Pipeline

[%inc ex_step_by_step.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `fun w => 0 == 0` with a filter that keeps words with more than 3 letters: `fun w => w.length > 3`
-   Replace `fun w => w` with `String.toUpper` to uppercase each word
-   Replace `""` with `" + "` as the intercalation separator
-   The expected output is `"HELLO + WORLD"`

</details>

### Write: Compose Three

[%inc ex_compose_three.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `upper` with a composition of all three functions
-   `exclaim ∘ reverse ∘ upper` means "uppercase, then reverse, then add !!"
-   Remember that `∘` reads right-to-left, so the first transformation goes on the right
-   The `#guard` expects `"OLLEH!!"` for the input `"hello"`

</details>

### Write: Wrap in a Namespace

[%inc ex_namespace.lean %]

<details markdown="1"><summary>hint</summary>

-   Wrap the `def pi` line with `namespace Math` (before) and `end Math` (after)
-   Then `Math.pi` will be a valid reference
-   The output should be `3.141590`

</details>

### Fix: Type Mismatch in Pipeline

[%inc ex_bug_pipe_type.lean %]

<details markdown="1"><summary>hint</summary>

-   `double` returns an `Int`, but `shout` expects a `String`
-   The pipeline `5 |> double |> shout` tries to feed an `Int` into a `String` function
-   Either change `shout` to work on `Int`, or remove it from the pipeline

</details>

### Fix: `open` Before Namespace

[%inc ex_bug_open_order.lean %]

<details markdown="1"><summary>hint</summary>

-   `open Colors` is on line 4, but the namespace is defined on line 6
-   Lean reads top to bottom: you can't open a namespace before it exists
-   Move `open Colors` after the `end Colors` line

</details>

### Fix: Wrong Number of Placeholders

[%inc ex_bug_pointfree.lean %]

<details markdown="1"><summary>hint</summary>

-   `List.map` expects a function that takes one argument
-   `(· - ·)` is a two-argument function (subtraction with two placeholders)
-   Use `(· - 2)` to subtract 2 from each element, or write an explicit `fun x => x - 2`

</details>

### Fix: `drop` vs. `take`

[%inc ex_bug_drop_take.lean %]

<details markdown="1"><summary>hint</summary>

-   `List.drop 2` removes the first 2 elements and keeps the rest
-   The `#guard` expects `[0, 10]`, which are the first two elements of `[0,1,2,3,4]` after doubling
-   Replace `drop` with `take` to keep the first 2 elements

</details>

### Write: Number Pipeline from Scratch

[%inc ex_pipeline_numbers.lean %]

<details markdown="1"><summary>hint</summary>

-   Start with `List.range 10` to get `[0, 1, …, 9]`
-   Pipe through `List.filter` to keep numbers divisible by 3: `(· % 3 == 0)`
-   Pipe through `List.map` to double each: `(· * 2)`
-   Pipe through `List.foldl` to sum: `(· + ·) 0`
-   Expected output is `36`

</details>

### Write: Make It Point-Free

[%inc ex_pointfree_greet.lean %]

<details markdown="1"><summary>hint</summary>

-   `addExcitement` does two things: uppercases, then appends `"!!!"`
-   Define an `exclaim` helper: `def exclaim (s : String) : String := s ++ "!!!"`
-   Then `addExcitementPF` is `exclaim ∘ String.toUpper`
-   The argument `s` disappears entirely: that's point-free

</details>

### Write: Zip and Format

[%inc ex_zip_pipeline.lean %]

<details markdown="1"><summary>hint</summary>

-   Use `List.zip names ages` to get `[("Alice", 25), ("Bob", 30), ("Carol", 35)]`
-   Pipe through `List.map` with a function that destructures each pair
-   Use `fun (name, age) => s!"{name}: {age}"` to format each pair
-   Expected output is `["Alice: 25", "Bob: 30", "Carol: 35"]`

</details>

</div>
