-- Write: convert this point-ful function to point-free using ∘
def addExcitement (s : String) : String :=
  let upper := s.toUpper
  upper ++ "!!!"

-- replace with: addExcitement should use ∘ and not name 's'
def addExcitementPF : String → String := addExcitement

#eval addExcitementPF "hello"
#guard addExcitementPF "hello" == "HELLO!!!"
