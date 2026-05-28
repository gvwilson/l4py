# Glossary

## C

<span id="computer_algebra_system">computer algebra system</span>
:   A program that manipulates mathematical expressions symbolically rather than numerically,
    such as Maple or Mathematica.

<span id="content_addressable">content-addressable</span>
:   Storage in which data is identified by a hash of its content rather than by a name or location.

<span id="currying">currying</span>
:   Transforming a function that takes multiple arguments into a sequence of functions each taking a single argument.

## D

<span id="destructuring">destructuring</span>
:   Unpacking values from a composite type such as a tuple or structure into individual bindings.

<span id="dsl">Domain Specific Language</span> (DSL)
:   A programming language specialized to a particular application domain, such as a build system or test framework.

## E

<span id="encapsulation">encapsulation</span>
:   Hiding the internal implementation of a component behind a stable interface,
    so that the implementation can change without affecting code that uses it.

<span id="effectful">effectful</span>
:   Describing a computation that performs side effects such as printing, reading input, or modifying state.

<span id="enumeration">enumeration</span>
:   A type defined by listing all of its possible values as named constructors, created with `inductive` in Lean.

## L

<span id="lake">Lake</span>
:   Lean's build tool and package manager, analogous to `cargo` in Rust.

<span id="lakefile">lakefile</span>
:   A configuration file (typically `lakefile.lean`) that declares a package's dependencies and build rules for Lake.

<span id="lemma">lemma</span>
:   A named intermediate statement that has been proved, used to simplify larger proofs by breaking them into smaller steps.

## M

<span id="monad">monad</span>
:   A design pattern that sequences computations while threading extra information such as I/O state through each step.

## O

<span id="omega_test">Omega test</span>
:   A decision procedure for integer Presburger arithmetic used by Lean's `omega` tactic to solve linear arithmetic goals automatically.

## P

<span id="partial">partial</span>
:   A keyword that tells Lean to skip termination checking for a function.
    Used when a function is known to terminate but Lean's automatic checker cannot prove it.

<span id="point_free">point-free style</span>
:   A way of defining functions by composing other functions without naming their arguments,
    using `∘` or `|>`. The "point" refers to the argument value itself.

<span id="prelude">prelude</span>
:   A standard library of basic types and functions automatically available in every Lean file without an explicit import.

<span id="product_type">product type</span>
:   A type that combines multiple values into a single compound value; tuples and structures are product types.

<span id="proof_term">proof term</span>
:   A value whose type is a proposition; produced by tactics such as `rfl` and `omega`.

<span id="proposition">proposition</span>
:   A claim expressed as a type in Lean's type system; has type `Prop`.

<span id="pure">pure</span>
:   Describing a function whose output depends only on its input arguments and that has no observable side effects.

## R

<span id="repl">Read-Eval-Print Loop</span> (REPL)
:   An interactive prompt where expressions are read, evaluated, and their results printed immediately.

<span id="ring">ring</span>
:   An algebraic structure with addition and multiplication satisfying rules such as commutativity,
    associativity, and distributivity; integers, natural numbers, and polynomials are all rings.

## S

<span id="sum_type">sum type</span>
:   A type whose value is exactly one of several distinct variants, defined with `inductive` in Lean.

<span id="syntactic_sugar">syntactic sugar</span>
:   Syntax that makes code easier to read or write without adding new capabilities to the language.

## T

<span id="termination_checking">termination checking</span>
:   Lean's automatic verification that every recursive function eventually stops.
    Functions that cannot be proved terminating must be marked `partial`.

<span id="tactic">tactic</span>
:   A command that constructs a proof automatically, such as `rfl`, `omega`, or `simp`.

<span id="tagged_union">tagged union</span>
:   Another name for a sum type; a value that is one of several variants with a runtime tag indicating which variant is held.

<span id="type_class">type class</span>
:   An interface that defines operations a type must support, such as `BEq` for equality
    or `Repr` for display. Instances are generated automatically with `deriving` or written by hand.

<span id="type_alias">type alias</span>
:   An alternative name for an existing type, created to improve readability without defining a new type.

<span id="type_parameter">type parameter</span>
:   A placeholder in a generic definition that is replaced with a concrete type when the definition is used, such as `α` in `List α`.

## W

<span id="workspace">workspace</span>
:   A collection of related Lean packages managed together by Lake in a shared build environment.
