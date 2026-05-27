import Lake
open Lake DSL

package «myproject» where
  name := "myproject"

-- Add an external dependency from a git repository
require Std from git
    "https://github.com/leanprover/std4" @ "main"

lean_exe «myproject» where
  root := `Main
