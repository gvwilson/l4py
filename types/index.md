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
