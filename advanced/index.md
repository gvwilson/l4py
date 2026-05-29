# Type Classes

<div class="callout" markdown="1">

-   Define a [%g type_class "type class" %] to specify an interface that multiple types can satisfy
-   Write `instance` declarations to implement a type class for a specific type
-   Use `[ClassName α]` constraints to write functions that work for any type with an instance
-   Combine multiple constraints and extend classes with `extends`
-   Understand `deriving` as automatic instance generation

</div>

-   So far, `deriving Repr` and `deriving BEq` have appeared without full explanation
-   This lesson explains the mechanism behind them: type classes
-   Like Python's abstract base classes, but checked at compile time with no runtime overhead

## Defining a Type Class

[%inc tc_basic.lean mark=tc-class %]

-   `class Describable (α : Type) where` introduces a new type class
    -   `α` is the type parameter — a placeholder for "whichever type implements this"
    -   `describe : α → String` is the required method: given a value, produce a string
-   Like Python's `class Describable(ABC): @abstractmethod def describe(self) -> str: ...`
    -   Unlike Python, the compiler enforces that every use has a valid implementation
-   No code is generated yet — `class` only defines the interface

## Writing an Instance

[%inc tc_basic.lean mark=tc-bool %]
[%inc tc_basic.lean mark=tc-int %]

-   `instance : Describable Bool where` tells Lean how to satisfy `Describable` for `Bool`
    -   The body provides all required methods
-   `instance : Describable Int where` is a completely separate declaration for `Int`
-   Like registering a Python `@singledispatch` handler, but checked at compile time
-   Two types, two instances: Lean picks the right one based on the type of the argument

[%inc tc_basic.lean mark=tc-use %]
[%inc tc_basic.out %]

-   `Describable.describe true` resolves to the `Bool` instance at compile time
-   `Describable.describe (42 : Int)` resolves to the `Int` instance
-   No runtime dispatch: the choice is made during type-checking

## Polymorphic Functions

[%inc tc_polymorphic.lean mark=tc-poly %]

-   `[Describable α]` is a [%g type_class "type class constraint" %]
    -   Read as: "for any type `α` that has a `Describable` instance"
    -   Square brackets `[...]` distinguish class constraints from ordinary arguments `(...)`
-   `showAll` works for `List Bool`, `List Int`, or any list whose element type has an instance
-   Like a Python `Generic` function with a `Protocol` bound, but resolved at compile time

[%inc tc_polymorphic.lean mark=tc-poly-use %]
[%inc tc_polymorphic.out %]

-   The same function body handles `Bool`, `Int`, and `String` lists
    -   Lean selects the correct `describe` implementation for each call

## Multiple Type Classes

[%inc tc_multiple.lean mark=tc-two-classes %]
[%inc tc_multiple.lean mark=tc-fruit %]

-   A single type can implement any number of classes
-   `Fruit` implements both `Describable` and `Weighable` independently
-   Like a Python class implementing multiple abstract base classes

[%inc tc_multiple.lean mark=tc-two-constraints %]

-   `[Describable α] [Weighable α]` requires both constraints
    -   The type must have instances for both classes to use `report`
-   The compiler verifies this at the call site — no runtime AttributeError

[%inc tc_multiple.lean mark=tc-multi-use %]
[%inc tc_multiple.out %]

## Extending Type Classes

[%inc tc_extend.lean mark=tc-extend %]

-   `extends Describable α` means `Verbose` inherits `describe` from `Describable`
    -   An instance of `Verbose` automatically satisfies `Describable`
-   Like Python's class inheritance, but for interfaces rather than implementations

[%inc tc_extend.lean mark=tc-extend-inst %]

-   The instance must provide all methods: both `describe` (inherited requirement) and `verboseDescribe`

[%inc tc_extend.lean mark=tc-extend-use %]
[%inc tc_extend.out %]

-   `label` only requires `Describable`, so `Int` (which has a `Verbose` instance) satisfies it
    -   A `Verbose` instance is also a `Describable` instance

## `deriving` Revisited

[%inc tc_deriving.lean mark=tc-deriving-what %]

-   `Repr` and `BEq` are ordinary type classes defined in the standard library
-   `deriving Repr` asks the compiler to generate a `Repr Color` instance automatically
    -   Lean can do this for any `inductive` type it fully understands
-   `deriving BEq` generates a `BEq Color` instance — structural equality
-   Not all classes can be derived: `Describable` cannot, because Lean does not know what string you want

[%inc tc_deriving.lean mark=tc-deriving-manual %]
[%inc tc_deriving.lean mark=tc-deriving-use %]
[%inc tc_deriving.out %]

-   `#eval Color.Red` uses the auto-generated `Repr` instance
-   `Color.Red == Color.Red` uses the auto-generated `BEq` instance
-   `Describable.describe Color.Green` uses the hand-written instance
-   Whenever you see `deriving X`, there is a type class `X` behind it
    -   You can always write the instance yourself instead — `deriving` is just a shortcut

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing String Instance

[%inc ex_bug_tc_missing_instance.lean %]

<details markdown="1"><summary>hint</summary>

-   `showAll ["a", "b"]` fails because there is no `Describable String` instance
-   Add an instance that returns the string itself: `describe s := s`
-   Like Python's `__str__` for built-in types

</details>

### Fix: Wrong Method Return Type

[%inc ex_bug_tc_wrong_method.lean %]

<details markdown="1"><summary>hint</summary>

-   The class declares `describe : α → String` but the instance returns `Nat`
-   The return type must match the class declaration
-   Use `s!"{n}"` to convert the `Nat` to a `String`

</details>

### Fix: Missing Type Class Constraint

[%inc ex_bug_tc_missing_constraint.lean %]

<details markdown="1"><summary>hint</summary>

-   `report` uses `Weighable.weight` but the signature only lists `[Describable α]`
-   The compiler can't find the `Weighable` instance because you didn't ask for it
-   Add `[Weighable α]` as a second constraint in the square brackets

</details>

### Fix: Missing Inherited Method

[%inc ex_bug_tc_extend_missing.lean %]

<details markdown="1"><summary>hint</summary>

-   `Verbose` extends `Describable`, so the instance must provide `describe` AND `verboseDescribe`
-   The compiler error says which method is missing
-   Add `describe n := s!"{n}"` to the instance body

</details>

### Fix: `deriving` Needs Parent Instances

[%inc ex_bug_tc_deriving_fail.lean %]

<details markdown="1"><summary>hint</summary>

-   `MyBox` tries to derive `Repr`, but its field `toy : Toy` needs `Repr` too
-   `deriving` chains: if a type contains another type, both must derive the class
-   Add `deriving Repr` to the `Toy` definition as well

</details>

### Write: A `Summarizable` Class

[%inc ex_tc_summarizable.lean %]

<details markdown="1"><summary>hint</summary>

-   Define `instance : Summarizable String where …`
-   If the string is 10 chars or shorter, return it as-is
-   Otherwise return `s.extract 0 10 ++ "..."` — use `String.extract` to slice

</details>

### Write: A `Doubleable` Class

[%inc ex_tc_doubleable.lean %]

<details markdown="1"><summary>hint</summary>

-   Define `instance : Doubleable Nat where …`
-   The `twice` method should multiply by `2`: `twice n := n * 2`
-   Simple arithmetic: this is the "hello world" of type class instances

</details>

### Write: A Function with Two Constraints

[%inc ex_tc_two_constraints.lean %]

<details markdown="1"><summary>hint</summary>

-   Change the signature to `def describeWeight [Describable α] [Weighable α] (x : α) : String`
-   Use `Describable.describe x` for the name and `Weighable.weight x` for the weight
-   Format with `s!"{...} weighs {...}g"`

</details>

### Write: Extend a Class

[%inc ex_tc_extend_class.lean %]

<details markdown="1"><summary>hint</summary>

-   Write `instance : Comparable Nat where …`
-   `size n := n` — the size of a Nat is itself
-   `biggerThan a b := a > b` — use the built-in `>` operator
-   Both methods must be provided; `Comparable` inherits `size` from `Measurable`

</details>

### Write: A Manual Display Instance

[%inc ex_tc_manual_repr.lean %]

<details markdown="1"><summary>hint</summary>

-   Write `instance : Display TrafficLight where …`
-   Use pattern matching on the three constructors
-   `| .Red => "red"`, `| .Yellow => "yellow"`, `| .Green => "green"`
-   This is what `deriving Repr` does automatically — you're doing it by hand

</details>

</div>
