# A Template Expander

<div class="callout" markdown="1">

-   Model a simple [%g template_engine "template engine" %] as a tree of nodes
-   Use [%g recursive_type "recursive inductive types" %] to represent template syntax
-   Walk the tree with an explicit [%g context "context" %] to substitute variables
-   Handle loops and conditionals with functional recursion

</div>

-   Template engines like [Jinja][jinja] or [Mustache][mustache] fill in placeholders with data
-   We'll build a minimal engine that supports variables, loops, and conditionals

## Template Values

[%inc code.lean mark=tval %]

-   `TVal` is a sum type for values in the template context
-   `TVal.Str s` holds a plain string
-   `TVal.List items` holds a list of contexts (one per loop iteration)

## Context

[%inc code.lean mark=context %]

-   A context is a list of `(name, value)` pairs
    -   Like a Python `dict` but implemented as an [%g association_list "association list" %]
-   `abbrev` creates a type alias without introducing a new wrapper type
    -   `Context` and `List (String × TVal)` are fully interchangeable
-   Each variable lookup scans the list linearly
    -   Small contexts: this is simple and fine
    -   Large contexts: a `HashMap` would be faster but isn't in the prelude (DEBT)

## Template Nodes

[%inc code.lean mark=tnode %]

-   `TNode` defines the abstract syntax tree of a template
-   Five constructors:
    -   `TNode.TText s`: literal text, output as-is
    -   `TNode.TVar name`: variable substitution `{% raw %}{{ var }}{% endraw %}`
    -   `TNode.TLoop name body`: loop over a list `{% raw %}{% for x in items %}...{% end %}{% endraw %}`
    -   `TNode.TIf name thenNode elseNode`: conditional
    -   `TNode.TSeq nodes`: a sequence of nodes in order
-   `TNode` is [%g recursive_data_type "recursive" %]: branches can contain more `TNode` trees

## Variable Lookup

[%inc code.lean mark=ctx-get %]

-   `ctxGet` searches the context for a variable by name
-   `ctx.find? (·.1 == name)` returns the first pair where the key matches
    -   `.1` accesses the first element of the `(String × TVal)` tuple
-   `.map (·.2)` extracts the value from the found pair
-   Returns `Option TVal`: `some` if found, `none` if not
    -   Like Python's `dict.get(name)` but more explicit

## Expanding Templates

[%inc code.lean mark=expand %]

-   `expand` is the heart of the engine: recursively walks the tree and builds output
-   Each node type has a different expansion rule:
    -   `TText`: output the string directly
    -   `TVar`: look up the variable; output its string value (or `""` if not found)
    -   `TLoop`: for each item in the list variable, expand the body with that item's context pushed on top
    -   `TIf`: check the variable; non-empty string or non-empty list → then branch, otherwise → else branch
    -   `TSeq`: expand all child nodes and concatenate results with `++`
-   `itemCtx ++ ctx` in `TLoop` pushes the loop variable's context in front
    -   The inner variable shadows any outer variable with the same name
-   `foldl` is used for both loops and sequences
    -   Accumulator starts as `""` and grows as each element expands

## Tests

[%inc code.lean mark=tests %]

-   Four templates are tested with `#guard`
-   Variable substitution: `"Hello, {{ name }}!"` with `name="World"` → `"Hello, World!"`
-   Loop: `<ul>` with two list items → full HTML string
    -   Each loop iteration gets its own sub-context: `[("x", "apples")]`, then `[("x", "bananas")]`
-   Conditional: `"visible"` when truthy, `"hidden"` when falsy or missing
-   Nested: variable inside conditional inside sequence
-   Notice the loop body uses `x` as the loop variable name
    -   The template defines `{{ x }}` in the body, and the data provides `x` in each item context

## A Hello Template

[%inc code.lean mark=hello %]

-   `helloTemplate` is a larger example: HTML with two variable substitutions
-   `helloCtx` provides values for both `"user"` and `"count"`
-   This template would render to:

```
<h1>Welcome, Alice!</h1>
<p>You have 3 items.</p>
```

## Running the Program

[%inc code.lean mark=main %]

-   `main` renders `helloTemplate` and prints the result
-   `IO.println output` displays the rendered HTML
-   Compile and type-check with:
    -   `lake env lean template/code.lean`
-   Run interactively with:
    -   `lean --run template/code.lean`
-   The output is plain text — adding file I/O is left as an exercise (see [io](@/io/))

<div class="exercise" markdown="1">

## Exercises

### Fix: Variable Not Found

[%inc ex_bug_tmpl_var.lean %]

<details markdown="1"><summary>hint</summary>

-   `ctxGet ctx "user"` returns `Option TVal`, but the code tries to use it directly as a string
-   Add a `match` expression to handle `some (TVal.Str s)` and `_` (not found)
-   Return `"unknown"` when the variable is missing

</details>

### Fix: Loop Skips Items

[%inc ex_bug_tmpl_loop.lean %]

<details markdown="1"><summary>hint</summary>

-   The loop only processes the first item in the list instead of all of them
-   `items.head?` returns only the first element (or `none` for empty)
-   Replace with `items.foldl` over all items, like the working `expand` function

</details>

### Fix: Empty String Is Truthy

[%inc ex_bug_tmpl_if_empty.lean %]

<details markdown="1"><summary>hint</summary>

-   An empty string `""` should be treated as falsy (like Python)
-   The function currently treats every `some` value as truthy
-   Add a check: `if s.isEmpty then ... else ...`

</details>

### Fix: Sequence Concatenation Order

[%inc ex_bug_tmpl_seq_order.lean %]

<details markdown="1"><summary>hint</summary>

-   `nodes.reverse.foldl` reverses the list before folding, producing backward output
-   Remove `.reverse` to keep the original left-to-right order

</details>

### Fix: Context Shadowing

[%inc ex_bug_tmpl_context.lean %]

<details markdown="1"><summary>hint</summary>

-   In the loop body, the inner context should shadow outer variables
-   The code uses `ctx ++ itemCtx` which puts the outer context first
-   Swap to `itemCtx ++ ctx` so the loop variable takes precedence

</details>

### Fix: Wrong Type in Lookup

[%inc ex_bug_tmpl_type.lean %]

<details markdown="1"><summary>hint</summary>

-   `ctxGet` returns `Option TVal`, but the code tries to treat it as `Option String`
-   `TVal` is not `String` — you need to pattern-match and extract the `TVal.Str s` value
-   Add `match` and return `""` when the variable has a different type or is missing

</details>

### Write: Greeting Template

[%inc ex_tmpl_greeting.lean %]

<details markdown="1"><summary>hint</summary>

-   Build a `TNode.TSeq` with `TNode.TText "Hello, "`, `TNode.TVar "name"`, and `TNode.TText "!"`
-   If `name` is missing, `expand` already returns `""` for missing variables
-   The `#guard` expects `"Hello, World!"` with `name="World"`

</details>

### Write: List Items

[%inc ex_tmpl_list_items.lean %]

<details markdown="1"><summary>hint</summary>

-   Use `TNode.TLoop` with list name `"items"` and a body that wraps `TNode.TVar "item"` in `"* "` prefix
-   The body should be `TNode.TSeq [TNode.TText "* ", TNode.TVar "item"]`
-   Use `TVal.List` with each item being `[("item", TVal.Str "...")]`

</details>

### Write: HTML Page

[%inc ex_tmpl_html_page.lean %]

<details markdown="1"><summary>hint</summary>

-   Build a full `<html><body>...</body></html>` structure using `TNode.TSeq`
-   Include a `TNode.TVar "title"` inside `<h1>` tags
-   The `#guard` checks for `<html><body><h1>My Site</h1></body></html>`

</details>

### Write: Show/Hide Section

[%inc ex_tmpl_show_hide.lean %]

<details markdown="1"><summary>hint</summary>

-   Use `TNode.TIf` to conditionally render the section
-   Check the `"show_section"` variable
-   When true, render "Section content"; when false, render ""

</details>

### Write: Repeat N Times

[%inc ex_tmpl_repeat.lean %]

<details markdown="1"><summary>hint</summary>

-   Create a context with a list of `n` identical items
-   Use `List.replicate n ctx` to create `n` copies of the same context
-   The loop body just references `TNode.TVar "word"`

</details>

### Write: Join With Separator

[%inc ex_tmpl_join.lean %]

<details markdown="1"><summary>hint</summary>

-   Expand the loop body to produce `item ++ ", "` for each item
-   Handle the trailing separator: either check if it's the last item, or trim after
-   `String.dropRight 2` can remove the trailing `", "` after expansion
-   Or use `items.foldl` directly with index awareness

</details>

</div>
