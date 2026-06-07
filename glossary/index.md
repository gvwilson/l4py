# Glossary

## A

<span id="association_list">association list</span>
:   A list of key-value pairs used as a simple lookup table, where
    each entry pairs a key with a value.

## C

<span id="chain_of_responsibility">Chain of Responsibility</span>
:   A design pattern in which a request is passed along a sequence of
    handlers, each of which either processes it or passes it on to the
    next.

<span id="computer_algebra_system">computer algebra system</span>
:   A program that manipulates mathematical expressions symbolically
    rather than numerically, such as Maple or Mathematica.

<span id="content_addressable">content-addressable</span>
:   Storage in which data is identified by a hash of its content
    rather than by a name or location.

<span id="context">context</span>
:   A mapping from variable names to values that a template engine
    uses when filling in placeholders.

<span id="currying">currying</span>
:   Transforming a function that takes multiple arguments into a
    sequence of functions each taking a single argument.

## D

<span id="destructuring">destructuring</span>
:   Unpacking values from a composite type such as a tuple or
    structure into individual bindings.

<span id="des">discrete event simulation</span>
:   A method of modeling a system where time advances in jumps from
    one event to the next rather than in fixed steps.

<span id="dsl">Domain Specific Language</span> (DSL)
:   A programming language specialized to a particular application
    domain, such as a build system or test framework.

## E

<span id="effectful">effectful</span>
:   Describing a computation that performs side effects such as
    printing, reading input, or modifying state.

<span id="encapsulation">encapsulation</span>
:   Hiding the internal implementation of a component behind a stable
    interface, so that the implementation can change without affecting
    code that uses it.

<span id="enumeration">enumeration</span>
:   A type defined by listing all of its possible values as named
    constructors, created with `inductive` in Lean.

## G

<span id="glob">glob</span>
:   A pattern-matching syntax for file names in which `*` matches any
    sequence of characters and `?` matches exactly one character.

## I

<span id="inductive_type">inductive type</span>
:   A type defined by listing its constructors; values are built from
    those constructors and taken apart with pattern matching.

<span id="inverse_cdf">inverse-CDF method</span>
:   A technique for generating random samples from a probability
    distribution by inverting its cumulative distribution function; if
    U is uniform on (0,1) then F⁻¹(U) follows the target distribution.

## L

<span id="lake">Lake</span>
:   Lean's build tool and package manager, analogous to `cargo` in
    Rust.

<span id="lakefile">lakefile</span>
:   A configuration file (typically `lakefile.lean`) that declares a
    package's dependencies and build rules for Lake.

<span id="language_server">language server</span>
:   A program that implements the Language Server Protocol to provide
    editor features such as error highlighting, autocompletion, and
    go-to-definition.

<span id="lemma">lemma</span>
:   A named intermediate statement that has been proved, used to
    simplify larger proofs by breaking them into smaller steps.

<span id="lcg">linear congruential generator</span>
:   A simple pseudorandom number generator defined by the recurrence
    `seed' = (A × seed + C) mod M`.  The same seed always produces the
    same sequence.

<span id="log_structured">log-structured</span>
:   A storage design where all writes are appended to a sequential log
    rather than updating records in place; the current value of a key
    is found by scanning the log for the most recent entry.

## M

<span id="monad">monad</span>
:   A design pattern that sequences computations while threading extra
    information such as I/O state through each step.

## O

<span id="omega_test">Omega test</span>
:   A decision procedure for integer Presburger arithmetic used by
    Lean's `omega` tactic to solve linear arithmetic goals
    automatically.

## P

<span id="partial">partial</span>
:   A keyword that tells Lean to skip termination checking for a
    function.  Used when a function is known to terminate but Lean's
    automatic checker cannot prove it.

<span id="point_free">point-free style</span>
:   A way of defining functions by composing other functions without
    naming their arguments, using `∘` or `|>`. The "point" refers to
    the argument value itself.

<span id="prelude">prelude</span>
:   A standard library of basic types and functions automatically
    available in every Lean file without an explicit import.

<span id="product_type">product type</span>
:   A type that combines multiple values into a single compound value;
    tuples and structures are product types.

<span id="proof_term">proof term</span>
:   A value whose type is a proposition; produced by tactics such as
    `rfl` and `omega`.

<span id="proposition">proposition</span>
:   A claim expressed as a type in Lean's type system; has type
    `Prop`.

<span id="pure">pure</span>
:   Describing a function whose output depends only on its input
    arguments and that has no observable side effects.

## R

<span id="rng">random number generator</span>
:   An algorithm that produces a sequence of numbers that approximates
    true randomness, driven by an initial seed value.

<span id="repl">Read-Eval-Print Loop</span> (REPL)
:   An interactive prompt where expressions are read, evaluated, and
    their results printed immediately.

<span id="recursive_data_type">recursive data type</span>
:   A data type that can contain instances of itself, such as a tree
    whose nodes may themselves be trees.

<span id="recursive_type">recursive type</span>
:   A type whose definition refers to itself, enabling structures of
    unbounded depth such as lists and trees.

<span id="ring">ring</span>
:   An algebraic structure with addition and multiplication satisfying
    rules such as commutativity, associativity, and distributivity;
    integers, natural numbers, and polynomials are all rings.

## S

<span id="saturating_subtraction">saturating subtraction</span>
:   Subtraction that stops at zero rather than producing a negative
    result, so `3 - 5 = 0` instead of `-2`.  Used by Lean's `Nat`
    type.

<span id="sum_type">sum type</span>
:   A type whose value is exactly one of several distinct variants,
    defined with `inductive` in Lean.

<span id="syntactic_sugar">syntactic sugar</span>
:   Syntax that makes code easier to read or write without adding new
    capabilities to the language.

## T

<span id="tactic">tactic</span>
:   A command that constructs a proof automatically, such as `rfl`,
    `omega`, or `simp`.

<span id="tagged_union">tagged union</span>
:   Another name for a sum type; a value that is one of several
    variants with a runtime tag indicating which variant is held.

<span id="template_engine">template engine</span>
:   A program that combines a template containing placeholders with a
    context of values to produce output such as an HTML page.

<span id="termination">termination</span>
:   The property of a recursive function that it always reaches a base
    case and halts rather than looping forever.

<span id="termination_checking">termination checking</span>
:   Lean's automatic verification that every recursive function
    eventually stops.  Functions that cannot be proved terminating
    must be marked `partial`.

<span id="tombstone">tombstone</span>
:   A marker record in a log-structured store indicating that a key
    has been deleted, rather than removing the original entry.

<span id="type_alias">type alias</span>
:   An alternative name for an existing type, created to improve
    readability without defining a new type.

<span id="type_class">type class</span>
:   An interface that defines operations a type must support, such as
    `BEq` for equality or `Repr` for display. Instances are generated
    automatically with `deriving` or written by hand.

<span id="type_parameter">type parameter</span>
:   A placeholder in a generic definition that is replaced with a
    concrete type when the definition is used, such as `α` in `List α`.

## W

<span id="workspace">workspace</span>
:   A collection of related Lean packages managed together by Lake in
    a shared build environment.
