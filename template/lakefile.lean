import Lake
open Lake DSL

package «template» where
  packagesDir := "../.lake/packages"

require batteries from git
  "https://github.com/leanprover-community/batteries" @ "32dc18cd"
