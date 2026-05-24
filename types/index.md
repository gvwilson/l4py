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
