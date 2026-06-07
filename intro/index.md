# Introduction

<div class="callout" markdown="1">

-   Understand what Lean is and how it differs from Python
-   Explore programming in a pure functional language

</div>

-   [Lean][lean] is a new(ish) programming language
    -   [%g pure "Pure" %]: functions always return the same output for the same input
    -   No mutable state: cannot modify data structures in place (create new ones)
    -   Side effects (like I/O) are tracked by the type system
-   See [%b Christiansen2023 %] for reference

## Tooling

-   Don't normally recommend specific editors…
-   …but Lean has committed heavily to [%g language_server "language servers" %]
-   These lessons were written using [VS Code][vs-code]