# Building Projects

<div class="callout" markdown="1">

-   Run single-file Lean programs from the command line with `lean`
-   Create and configure multi-file projects with Lake
-   Write a lakefile to define executables and libraries
-   Import code from other files in the same project with `import`
-   Add external package dependencies with `require`

</div>

-   So far we have run Lean files one at a time
-   Real projects have multiple files, dependencies, and build steps

## Single-File Programs

[%inc single_file.lean %]
[%inc single_file.out %]

-   Run a single Lean file from the terminal with `lean filename.lean`
    -   Like `python script.py`
-   `def main : IO Unit` is the entry point
    -   Lean executes `main` when you run the compiled file
-   For experiments and learning, single files are fine
    -   For anything larger, use [%g lake "Lake" %]

## What Is Lake?

-   Lake is Lean's build system and package manager
    -   Like Python's `uv`, Rust's `cargo`, or Node's `npm`
-   A [%g lakefile "lakefile" %] called `lakefile.lean` describes the project
    -   Name, source files, and dependencies
    -   It is a Lean file that uses the Lake [%g dsl "DSL" %]
-   `import Lake` and `open Lake DSL` bring the build language into scope
-   `package` names the project; `lean_exe` defines an executable target

## Creating a Project

[%inc lake_new.lean %]
[%inc lake_new.out %]

-   `lake new MyProject` creates a fresh project directory
    -   Generates a `lakefile.lean`, a `Main.lean`, and a `.lake/` cache directory
    -   Like `uv init` or `cargo new`
-   `lake init` does the same thing inside an existing directory
-   The [%g workspace "workspace" %] is the directory that contains `lakefile.lean`
    -   All build commands are run from the workspace root

## Minimal Lake File

-   `package` names the project; the `«»` angle-quote syntax allows spaces in names
    -   Type `\f<<` and `\f>>` to get the angle quotes
-   `lean_exe` defines an executable target (a compiled binary you can run)
    -   `root := \`Main` tells Lake to look for `def main` in `Main.lean`
        -   The backtick before `Main` is Lean's syntax for a `Name` literal
        -   It's like writing `"Main"` but using Lean's internal name type instead of a string

## Building from the Command Line

[%inc lake_build.lean %]
[%inc lake_build.out %]

-   `lake build` compiles all targets in the project
    -   Like `cargo build` or `uv run python -m build`
-   The compiled binary lands in `.lake/build/bin/`
-   Lake only recompiles files that have changed
    -   Fast for large projects because the `.lake/` directory caches intermediate results
-   Lake also accepts a target name: `lake build MyTarget`

## Running an Executable

-   `lake exe targetname` builds and runs an executable in one step
    -   Like `cargo run` in Rust
-   If the project is already built, `lake exe` skips the compile step
-   The executable name is whatever you wrote after `lean_exe` in `lakefile.lean`

## Multiple Source Files

[%inc multi_file.lean %]
[%inc multi_file.out %]

-   Split large projects into multiple `.lean` files
    -   Each file becomes a module that other files can import
-   File names must start with a capital letter
    -   `Helpers.lean` → module `MyProject.Helpers`
    -   The project name prefix comes from `package` in `lakefile.lean`
-   Use `namespace … end` to group related definitions within a file

## Importing Your Own Modules

[%inc import_module.lean %]
[%inc import_module.out %]

-   `import MyProject.Helpers` brings `Helpers.lean` into scope
    -   The full path is `PackageName.FileName` (no `.lean` extension)
-   After importing, call functions with the namespace prefix: `Helpers.greet`
    -   Or `open Helpers in greet` to drop the prefix for one expression
-   Import order matters: Lean processes files top to bottom
    -   Cannot have circular imports

## Libraries vs. Executables

[%inc lib_vs_exe.lean %]
[%inc lib_vs_exe.out %]

-   `lean_lib` compiles source files into a reusable library
    -   Produces `.olean` files (pre-compiled Lean objects) but no binary
    -   Other packages can depend on it with `require`
    -   Lake knows to create a library because you used `lean_lib`: the keyword determines the target type
-   `lean_exe` links source files into a runnable binary
    -   Must have a `def main : IO Unit` in the root file
-   One project can define both: libraries and executables are separate targets

## Running Lean in Project Context

[%inc lake_env.lean %]
[%inc lake_env.out %]

-   `lake env lean file.lean` runs `lean` with the project's modules on the path
    -   Without `lake env`, imports that refer to your project's modules fail
    -   Like Python's `uv run python script.py` vs. bare `python script.py`
-   Use `lake env lean` for one-off scripts that need project modules but aren't targets

## Adding a Dependency

[%inc add_dep.lean %]
[%inc add_dep.out %]

-   `require PackageName from git "url" @ "ref"` declares an external dependency
    -   Lake fetches the package and caches it in `.lake/packages/`
-   After editing `lakefile.lean`, run `lake update` to download the dependency
    -   Then `import` its modules just like your own
-   `Std` is the Lean standard library extension; `Mathlib` is the math library
    -   Both are added with `require`
-   For local packages not on a git remote, use a path:
    ```lean
    require MyLib from "../my-lib"
    ```
    -   Like a Python editable install or a Rust path dependency

## Namespaces Across Files

[%inc namespace_files.lean %]
[%inc namespace_files.out %]

-   By convention, namespace names should match the module import path
    -   File `MathUtils/Basic.lean` → module `MyProject.MathUtils.Basic`
    -   Namespace inside that file: `MathUtils.Basic`
-   This isn't enforced by the compiler, but it makes code easier to navigate
    -   Like Python's module names matching the file names
-   `open Namespace in expr` uses the namespace for one expression
    without `open` polluting the whole file

<div class="exercise" markdown="1">

## Exercises

### Fix: Missing Import

[%inc ex_bug_missing_import.lean %]

<details markdown="1"><summary>hint</summary>

-   `Utils.greet` is called but `Utils` is never imported
-   Add `import MyProject.Utils` at the top of the file

</details>

### Fix: Wrong Target Type

[%inc ex_bug_wrong_target.lean %]

<details markdown="1"><summary>hint</summary>

-   `lean_lib` creates a library; it cannot be run directly
-   Change `lean_lib` to `lean_exe` to create an executable target
-   Also change the field from `srcDir` to `root := \`Main`

</details>

### Fix: Wrong Module Name Case

[%inc ex_bug_module_name.lean %]

<details markdown="1"><summary>hint</summary>

-   Lean module names are derived from filenames, which start with a capital letter
-   `helpers` should be `Helpers` to match `Helpers.lean`
-   Change `import MyProject.helpers` to `import MyProject.Helpers`

</details>

### Fix: Missing `main` Function

[%inc ex_bug_missing_main.lean %]

<details markdown="1"><summary>hint</summary>

-   Executables need `def main : IO Unit` as their entry point
-   Add `def main : IO Unit := IO.println greet` to the file
-   Without `main`, Lake cannot produce a runnable binary

</details>

### Fix: Wrong Namespace in Call

[%inc ex_bug_namespace.lean %]

<details markdown="1"><summary>hint</summary>

-   `func` is defined inside `namespace Foo`, so it is `Foo.func`
-   Change `Bar.func` to `Foo.func` to match the actual namespace

</details>

### Fix: Wrong Source Directory

[%inc ex_bug_root_module.lean %]

<details markdown="1"><summary>hint</summary>

-   `srcDir := "source"` tells Lake to look for `.lean` files in `source/`
-   But the project files are in `src/`
-   Change `srcDir := "source"` to `srcDir := "src"`

</details>

### Write: Complete a Lake File

[%inc ex_write_lakefile.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace the `TODO` comment with `lean_exe «greeter» where`
-   Add `root := \`Main` indented under that line
-   The `«greeter»` must match the name you want to use in `lake exe greeter`

</details>

### Write: Add a `main` Function

[%inc ex_write_main.lean %]

<details markdown="1"><summary>hint</summary>

-   Add `def main : IO Unit := IO.println "Hello, Lake!"` to the file
-   `IO.println` prints a string followed by a newline
-   No `do` block needed for a single IO action

</details>

### Write: Implement a Module Function

[%inc ex_write_module.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace `""` with `s!"Hello, {name}!"`
-   The `#eval` call at the bottom will print `"Hello, world!"` when correct

</details>

### Write: Add an Import

[%inc ex_write_import.lean %]

<details markdown="1"><summary>hint</summary>

-   Add `import MyProject.Greeter` at the top of the file
-   The import path matches the file path: `MyProject/Greeter.lean`
-   After importing, `Greeter.greet` becomes available

</details>

### Write: Add a Library Target

[%inc ex_write_lib.lean %]

<details markdown="1"><summary>hint</summary>

-   Replace the `TODO` comment with `lean_lib MathLib { }`
-   A library target does not need a `root` unless you want a specific entry module
-   Build it with `lake build MathLib`

</details>

### Write: Fix the Namespace Name

[%inc ex_write_namespace.lean %]

<details markdown="1"><summary>hint</summary>

-   The namespace `StrUtil` doesn't match the module name `StringUtils`
-   Change both `namespace StrUtil` and `end StrUtil` to `StringUtils`
-   Then callers can use `StringUtils.shout` which matches the file name

</details>

</div>
