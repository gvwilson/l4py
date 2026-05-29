-- Verbose extends Describable, so an instance must provide both methods.
-- This instance only provides verboseDescribe. Add the missing method.
class Describable (α : Type) where
  describe : α → String

class Verbose (α : Type) extends Describable α where
  verboseDescribe : α → String

-- BUG: missing the inherited `describe` method
instance : Verbose Int where
  verboseDescribe n :=
    if n < 0 then s!"negative: {n}"
    else if n == 0 then "zero"
    else s!"positive: {n}"

#guard Describable.describe (42 : Int) == "42"
#guard Verbose.verboseDescribe (42 : Int) == "positive: 42"
#guard Verbose.verboseDescribe (-3 : Int) == "negative: -3"
