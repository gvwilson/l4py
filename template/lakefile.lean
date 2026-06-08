import Lake
open Lake DSL

package «template» where
  packagesDir := "../.lake/packages"

require batteries from git
  "https://github.com/leanprover-community/batteries" @ "460b61adc7d183e43db2b99ac6c1dede9f7a76df"
