# Types

-   A structure is a [%g product_type "product type" %]
    -   Possible values are the cross-product of the values of the first field
        with the values of the second field, etc.
-   Explore other kinds of types

## Sum Types

[%inc sum_types.lean %]
[%inc sum_types.out %]

-   An [%g sum_type "sum type" %] is a choice between alternatives
    -   The possible values are the sum of the possibilities of each alternative
    -   Use `inductive` to define one: we'll explain the name later (DEBT)
-   `StringOrInt` is a type whose values wrap either a `String` or an `Int`
    -   `StringOrInt.str` constructs a string-flavored value
    -   `StringOrInt.num` constructs a number-flavored value
-   `deriving Repr` is like Python's `__repr__`
    -   We'll explain why it's called `deriving` later (DEBT)
-   Since every element of the list has type `StringOrInt`, the list is homogeneous
-   Use `match` to extract the wrapped value
    -   The compiler checks that you handle both cases
-   We've already seen a sum type: `Option` in [basics](@/basics/) is either `some` or `none`

## Trees

[%inc binary_tree.lean %]
[%inc binary_tree.out %]

-   `inductive` can define recursive types, not just flat sums
    -   `Tree` is either a `leaf` containing a `String`…
    -   …or a `node` containing two `Tree`s
-   Like defining a Python class where each instance is either a leaf or a branch
    -   But the compiler enforces that you can't mix the two accidentally
-   This is why the keyword is `inductive`
    -   The definition refers to itself: `node` takes two `Tree` arguments
    -   Like mathematical induction: base cases (`leaf`) and inductive steps (`node`)
-   `totalLength` uses `match` on the tree shape
-   Compiler checks that code handles both `leaf` and `node` cases
    -   Same exhaustiveness guarantee as `match` on lists

## Polymorphism

[%inc polymorphism.lean %]
[%inc polymorphism.out %]

-   Add a [%g type_parameter "type parameter" %] to make a type work with any element type
-   `α` (alpha) is the conventional Greek letter for the first type parameter
    -   Type it as `\a` in Lean
-   Same `inductive` shape as the string-only `Tree` above
    -   But now `leaf` can hold any type
-   `numTree` and `strTree` are the same shape, different leaf types
    -   The compiler prevents you from putting a string leaf in `numTree`
-   `countLeaves` works on `Tree α` for any `α`
    -   Uses `_` in the `leaf` branch because it doesn't need the value, just the count

## Enumerations

[%inc enum.lean %]
[%inc enum.out %]

-   An [%g enumeration "enumeration" %] is a sum type where no constructor carries data
    -   Like Python's `enum.Enum`
-   `inductive Season` defines four possible values with no extra payload
-   `deriving BEq` generates the `==` operator
    -   Without it, you can't compare `Season` values
    -   We'll explain the name `BEq` later (DEBT)

## Sum Types with Data

[%inc shape.lean %]
[%inc shape.out %]

-   Constructors in a sum type can carry one or more data fields
    -   `Shape.circle` takes a `Float` for the radius
    -   `Shape.rect` takes two `Float`s for width and height
-   Like a [%g tagged_union "tagged union" %] where each tag stores different-shaped data
    -   Python equivalent: a `@dataclass` discriminator field plus a union of subclasses

## Pattern Matching on Sum Types

[%inc match_sum.lean %]
[%inc match_sum.out %]

-   `match` on a sum type works exactly like `match` on a list
    -   Each constructor gets its own branch
    -   The compiler checks that every constructor is handled
-   `area` is written in definition-by-cases style
    -   `Shape.circle r => …` [%g destructuring "destructures" %] the constructor and binds `r`
-   If you forget a case, the compiler rejects the definition entirely
    -   Unlike Python, where a missing `case` silently falls through or raises at runtime

## `deriving` Explained

[%inc deriving.lean %]
[%inc deriving.out %]

-   `deriving` tells the compiler to generate code for common type classes
    -   (DEBT) A bigger topic we'll return to later
-   `deriving Repr` generates a readable display for `#eval`
-   `deriving BEq` generates `==`
    -   Without it, comparing `Color` values is a compile error

## `Option` is a Sum Type

[%inc option_revealed.lean %]
[%inc option_revealed.out %]

-   `Option` isn't magic: it's defined as an `inductive` type in the standard library
    -   `Option.none` is a constructor with no data
    -   `Option.some` is a constructor that carries one value of type `α`
-   Because it's a regular sum type, you can pattern match on it directly
    -   No special syntax: the same `match` you already know
-   Everything we learned about `Option` in [basics](@/basics/) was sum types all along

## `List` is a Recursive Inductive Type

[%inc list_revealed.lean %]
[%inc list_revealed.out %]

-   `List` is also an `inductive` type with two constructors
    -   `nil` for the empty list (written `[]`)
    -   `cons` for adding an element to the front (written `head :: tail`)
    -   The name "cons" is short for "construct", and goes back to the 1950s
-   `::` is just [%g syntactic_sugar "syntactic sugar" %] for `List.cons`
-   `[]` is syntactic sugar for `List.nil`
-   This is why `match` on lists uses `[]` and `head :: tail`:
    they are the two constructors of the underlying inductive type

## Computing on Inductive Types

[%inc expr_eval.lean %]
[%inc expr_eval.out %]

-   Create a tiny expression language in four lines
    -   `Expr.num` wraps a plain integer
    -   `Expr.add` and `Expr.mul` each contain two sub-expressions
-   `eval` is a recursive function that mirrors the type structure
-   "Define a type, then write functions by cases" is the heart of Lean

## Generic Sum Types

[%inc result.lean %]
[%inc result.out %]

-   A sum type can have multiple type parameters
    -   `Result α β` is generic over both the success type and the error type
-   Like Rust's `Result` or Haskell's `Either`
-   Cleaner than Python's convention of returning `(value, error)` tuples
    -   The compiler forces the caller to handle both `ok` and `err`

## `match` with Conditions

[%inc match_guard.lean %]
[%inc match_guard.out %]

-   Sometimes constructors alone aren't enough: you need finer discrimination
-   `match` arms are just expressions, so you can use `if`/`else if`/`else` inside them
    -   The `n'` pattern matches any `Int`, then the conditional further refines the result
    -   Pronounced "en prime"
-   The compiler still checks that the `match` is exhaustive
    -   A single `n'` branch covers all `Int` values, so no catch-all is needed here

## Nested Patterns

[%inc nested_match.lean %]
[%inc nested_match.out %]

-   Types combine: you can have an `Option` containing a `List`
-   `match` handles this by nesting patterns
    -   `Option.some []` matches a `some` wrapping an empty list
    -   `Option.some [n]` destructures the list inside the option
-   Like Python's structural pattern matching (`match`/`case`)
    -   But again, the compiler verifies that every combination is covered

## Product Types are Inductive

[%inc product_inductive.lean %]
[%inc product_inductive.out %]

-   `structure` is syntactic sugar for `inductive` with exactly one constructor
    -   `Point.mk 1.0 2.0` and `{ x := 1.0, y := 2.0 }` are equivalent
-   Product types (structures) and sum types are both `inductive` under the hood
    -   A structure has one constructor; a sum type has two or more
-   The type system unifies both concepts

## A Command Interpreter

[%inc commands.lean %]
[%inc commands.out %]

-   Define a tiny domain-specific language in three lines of type definition
    -   `Cmd.forward n` moves forward `n` steps
    -   `Cmd.turn d` turns `d` degrees
    -   `Cmd.say msg` prints a message
-   `run` is an interpreter: pattern matching plus recursion over the command list
-   This is the payoff: define your data shapes with `inductive`, then process them with `match`
