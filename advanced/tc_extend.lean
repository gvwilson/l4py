-- mccole: tc-extend
-- extends inherits all methods of the parent class
class Describable (α : Type) where
  describe : α → String

class Verbose (α : Type) extends Describable α where
  verboseDescribe : α → String
-- mccole: /tc-extend

-- mccole: tc-extend-inst
-- An instance of Verbose must provide both methods
instance : Verbose Int where
  describe n      := s!"{n}"
  verboseDescribe n :=
    if n < 0 then s!"negative: {n}"
    else if n == 0 then "zero"
    else s!"positive: {n}"
-- mccole: /tc-extend-inst

-- mccole: tc-extend-use
-- Any function expecting Describable also accepts Verbose
def label [Describable α] (x : α) : String :=
  s!"[{Describable.describe x}]"

#eval label (42 : Int)
#eval label (-7 : Int)
#eval Verbose.verboseDescribe (0 : Int)
#eval Verbose.verboseDescribe (5 : Int)
-- mccole: /tc-extend-use
