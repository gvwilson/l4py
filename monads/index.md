# Monads

A monad is a way to structure computations that carry extra context
without manually threading that context through every function call.
If you’re coming from Python,
the cleanest way to think about it is that
a monad is a way to chain operations without explicitly passing extra arguments.
Monads aren't just for input and output;
they can also be used for:

-   possible failure (`None`, exceptions)
-   async execution (`await`)
-   logging
-   random number generation
-   dependency injection
-   parsing context

## Ordinary function composition

Normal composition is straightforward:

```python
def double(x):
    return x * 2

def increment(x):
    return x + 1

increment(double(10))   # 21
```

The output of one function becomes the input of the next.
But now suppose computations can fail.

```python
def parse_int(s):
    try:
        return int(s)
    except:
        return None

def reciprocal(x):
    if x == 0:
        return None
    return 1 / x
```

Now chaining becomes annoying:

```python
x = parse_int("10")
if x is not None:
    y = reciprocal(x)
else:
    y = None
```

As programs grow,
this repetitive “check the context” logic spreads everywhere.
A monad abstracts this pattern.

## The Core Idea

Instead of values:

```python
x
```

we work with values inside a context:

```python
Maybe(x)
```

The monad defines:

1.  how to put a value into the context, and
1.  how to chain operations while preserving the context.

Depending on the language,
the chaining operation is called `bind`, `flatMap`, or `>>=`,
none of which are particularly memorable.

Here's a tiny `Maybe` monad in Python:

```python
class Maybe:
    def __init__(self, value):
        self.value = value

    def bind(self, f):
        if self.value is None:
            return Maybe(None)
        return f(self.value)

    @staticmethod
    def unit(x):
        return Maybe(x)

    def __repr__(self):
        return f"Maybe({self.value})"
```

Functions now return `Maybe` values:

```python
def parse_int(s):
    try:
        return Maybe(int(s))
    except:
        return Maybe(None)

def reciprocal(x):
    if x == 0:
        return Maybe(None)
    return Maybe(1 / x)
```

Now composition becomes:

```python
result = (
    Maybe.unit("10")
        .bind(parse_int)
        .bind(reciprocal)
)

print(result)
```

(The outer parentheses are there to force evaluation.)
The key thing is that failure propagation happens automatically.
Without monads:

```python
f(g(h(x)))
```

only works for plain values.
With monads:

```python
m.bind(f).bind(g).bind(h)
```

works even when every step carries context.
The monad controls:

* how values flow
* how context combines
* how failure/async/state/etc propagate

## Examples in Other Languages

Monadic ideas show up regularly in other languages.
For example, consider this Python code:

```python
data = await fetch_user()
posts = await fetch_posts(data.id)
```

Each computation is inside an `async` context.
We are not manually managing callbacks or event loops;
the async machinery handles the context propagation.
Similarly, in JavaScript, we can write:

```js
user?.address?.street
```

This is monad-like behavior:
if anything is missing, propagate absence automatically.

## Why Bother?

Monads solve a major problem in pure functional languages:

> How do we sequence computations when functions cannot mutate state
> and must return the same value for any given set of inputs?

The trick is to treat each context as unique.
In pseudo-Python, we turn:

```python
first_line = reader.readline()
second_line = reader.readline()
```

into:

```python
first_line, second_context = reader.readline(first_context)
second_line, third_context = reader.readline(second_context)
```

Since each context is unique,
`readline()` is allowed to return different values from each call,
which it is *not* allowed to do in the original code.
Similarly,
when we're doing output,
we turn:

```python
first_num = writer.write(some_string)
second_number = writer.write(some_string)
```

into:

```python
second_context, first_num = writer.write(first_context, some_string)
third_context, second_number = writer.write(second_context, some_string)
```

## The Two Essential Operations

A monad is defined by two operations.
The first combines a normal value with a context:

```python
Maybe.unit(5)
# Maybe(5)
```

The second chains computations:

```python
Maybe(5).bind(f)
```

where:

```python
def f(a):
    return Maybe(b)
```

`bind` extracts the inner value,
applies the function,
and preserves the context rules.

<div class="callout" markdown="1">

Another way to look at monads is that
they are a way to handle nested contexts.
Without `bind`, we would write:

```python
Maybe(Maybe(5))
```

Bind is essentially map, then flatten,
which is why some languages call it `flatMap`.

</div>

## So What's the Big Deal?

Monads have a reputation for being complex.
There are three reasons for this:

1.  Functional languages make them unavoidable,
    so beginners hit them early in languages like Lean.

1.  Tutorials often start too abstractly.
    "A monad is a monoid in the category of endofunctors"
    is mathematically correctly but pedagogically horrible.

1.  Monads are more about composition than data structures.
    Programmers coming from conventional languages are used to thinking about
    classes, objects, and state.
    Monads are about computation flow and context propagation,
    which is a different axis of abstraction.

## The `do` Notation

Let's go back to an earlier Python example:

```python
result = (
    Maybe.unit("10")
        .bind(parse_int)
        .bind(reciprocal)
)

print(result)
```

All those `bind()` calls make it hard to see what's happening,
so Lean provides the `do`/`←` notation.
Each function returns an `Option` instead of a `Maybe`:

```lean
def parseNat? (s : String) : Option Nat := s.toNat?

def reciprocal? (n : Nat) : Option Float :=
  if n == 0 then none else some (1.0 / n.toFloat)
```

The `do`/`←` notation replaces the `.bind()` chain:

```lean
def compute : Option Float := do
  let n ← parseNat? "10"
  let r ← reciprocal? n
  return r
```

Each `←` extracts the value from the `Option` context.
If any step returns `none`, the whole computation short-circuits to `none`,
which is exactly what `.bind()` did manually in Python.
