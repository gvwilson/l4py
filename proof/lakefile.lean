import Lake
open Lake DSL

package «proof» where
  name := "proof"
  packagesDir := "../.lake/packages"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4"
