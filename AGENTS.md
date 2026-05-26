# l4py

## Project Overview

**Lean for Python Programmers** — a one-day (four-lesson) introduction to Lean 4 for
working Python programmers. Target learner has zero prior exposure to pure
functional programming, advanced type systems, or theorem provers. All examples
run locally via the `lean` compiler; no browser sandbox or IDE-specific features
are assumed.

- **Source**: Markdown + `.lean` source files in `basics/`, `types/`, `intro/`, `finale/`
- **Build**: `mccole` static-site generator (pip package, configured in `pyproject.toml`)
- **Output**: `docs/` (committed HTML; `docs/.nojekyll` for GitHub Pages)
- **Repo**: <https://github.com/gvwilson/l4py>
- **Author**: Greg Wilson (gvwilson@third-bit.com)

## Four Lessons

| Lesson     | Slug      | Status      |
|------------|-----------|-------------|
| Intro      | `intro/`  | Stub — one line, links to Christiansen2023 |
| Basics     | `basics/` | **Complete** — 14 sections, 22 `.lean` files + matching `.out` files |
| Types      | `types/`  | **Complete** — 16 sections, 31 `.lean` files |
| Pipes      | `pipes/`   | **Complete** — 12 sections, 11 `.lean` files + 12 exercise `.lean` files |
| IO         | `io/`      | In progress |
| Archive    | `archive/` | **Complete** — capstone: content-addressable file archiver |
| Conclusion | `finale/`  | Stub — empty |

## Lesson Structure & Style

### Prose voice

- Terse, bullet-point commentary after each code block. No paragraphs of exposition.
- Direct comparisons to Python: "Like Python's f-strings", "Like a Python dataclass",
  "Unlike Python, where forgetting to check for None is a runtime error."
- Tutorial style: each section introduces exactly one new concept through a
  short code sample and a few explanatory bullets.
- Errors are shown deliberately: `conditional_incomplete.lean` demonstrates
  a missing `else` branch with its compiler error in the matching `.out` file.
- Editorial asides are present: "That's a hell of an error message…", "Which is a
  horrible usability decision", "Which is an even worse usability decision, but
  we're stuck with it."
- `(DEBT)` markers indicate things to explain later: "we'll explain the name later
  (DEBT)", "We'll explain why it's called `deriving` later (DEBT)".

### Code style

- Every `.lean` file is a standalone, self-contained example — typically 3-10 lines.
- No `import` statements; all examples use only the Lean prelude.
- Code is clean and minimal:
  - `def` for definitions, `:=` for assignment
  - `#eval` to print results at compile time
  - `#check` to inspect types
  - `#guard` for compile-time assertions
  - `--` for comments
- Function naming uses camelCase: `sumList`, `circleArea`, `firstOrZero`.
- Pattern matching uses `match xs with | ... => ...` syntax with `[]` base cases
  and `x :: xs` head/tail decomposition.
- Cons `::` used for destructuring; `List.length` for length; `Float.sqrt` for math.
- Anonymous functions: `fun args => expr` then later `(· + ·)` for idiomatic shorthand.
- Structures: `structure Name where field : Type`, create with `{ field := val }`,
  update with `{old with field := newVal}`.
- Product type tuple notation: `Int × String` (Unicode `\times`), access with `.1`/`.2`.
- String interpolation: `s!"text {expr}"` (like Python f-strings).

### Topics covered in Basics (complete)

1. `#eval` for arithmetic
2. `def` with explicit type annotations (`Int`, `Float`, `String`, `List`)
3. Strict typing error example
4. `#guard` compile-time checks
5. `s!"..."` string interpolation
6. `List` type: homogeneous, 0-indexed, `List.length`
7. Simple functions: no `return`, no parens in calls, currying (`func_partial.lean`)
8. `if`/`else if`/`else` as expression — with deliberate incomplete/inconsistent examples
9. `match` pattern matching with `|` and `=>` and `_` catch-all
10. Recursion on lists with `::` destructuring and exhaustiveness checking
11. `map`, `filter`, `foldl` with anonymous functions
12. `let` bindings for local definitions
13. Tuples: `×` type separator, `.1`/`.2` access, destructuring `let (x, y) := p`
14. `Option` type: `Option.some` / `Option.none`, forced handling
15. `structure`: define, create with `{}`, field access, functional update `{old with ...}`
16. `#check` for type inspection, type inference, `Nat` vs `Int`
17. Idiomatic Lean: `·` placeholders, Unicode `≥` / `≤`

### Topics in Types (in progress)

- Sum types via `inductive`, `deriving Repr`, pattern matching with `match`
- Connection to `Option` from basics lesson

## Build System (mccole)

Configured in `pyproject.toml` under `[tool.mccole]`:
- `brand = "L4Py"`
- `skips` ignore `.lean`, `.out`, `*~`, `bin/`, `docs/`, `uv.lock`

**Tasks** (run via `task` or `uv run task`):
| Task     | Command                                       |
|----------|-----------------------------------------------|
| `regen`  | `python bin/regenerate.py basics` — re-runs `.lean` files to generate `.out` |
| `bib`    | `mccole bib` — validates bibliography entries   |
| `clean`  | removes `*~` backups and `*/*.out` files        |
| `check`  | `mccole check` + `typos` spell check            |
| `serve`  | `python -m http.server -d docs 8000`            |
| `site`   | `mccole build --src . --dst docs` + touches `.nojekyll` |

**Shortcodes used in markdown**:
- `[%inc file.lean %]` — include a file's contents (used for code + output)
- `[%b key %]` — bibliography citation
- `[%g key "text" %]` — glossary link with display text
- `@/slug/` — cross-reference to another lesson page

**regenerate.py**: walks `sys.argv[1:]` subdirectories, runs `lake env lean` on
each `.lean` file, writes stdout to `.out` file. Skips if `.out` is newer than `.lean`.

## Templates & CSS

- `_templates/page.html` — Jinja2 template with Chota CSS framework, dropdown
  nav for lessons/appendices, footer with prev/next navigation, Katex math support,
  optional slides link.
- `_static/chota.css` — micro CSS framework (3KB)
- `_static/mccole.css` — mccole-specific overrides
- `_static/pygments.css` — syntax highlighting
- `_static/slides.css`, `_static/slides.js` — Shower.js presentation support
- `_templates/slides.html`, `_templates/single_page.html` — alternate templates

## Glossary

Used via `[%g key "text" %]` shortcode in lesson markdown; entries in alphabetical
order by text (not key) under H2 heading of first letter.

## Bibliography

Single entry: Christiansen2023 (*Functional Programming in Lean*, Microsoft, 2023).
Referenced via `[%b Key1 Key2 %]`.

## Other Files

- `CODE_OF_CONDUCT.md` — standard contributor covenant
- `CONTRIBUTING.md` — contact info, setup instructions (uv + venv + `uv sync`), FAQ
- `LICENSE.md` — license file
- `uv.lock` — dependency lockfile
- `docs/` — committed built HTML (all lessons rendered)

## Conventions to Follow When Editing

- Every `.lean` file must have a matching `.out` file (regenerate with `task regen`).
- Keep commentary terse: 2-5 bullets per code block, Python comparisons where helpful.
- Show errors deliberately: include the `.out` with compiler error text.
- Use `(DEBT)` for promises to explain later.
- Function names: camelCase. Two-space indentation in `.lean` files.
