-- Fix: the composition order is wrong
-- should add 1 then double, not double then add 1
def addOne (x : Int) : Int := x + 1
def double (x : Int) : Int := x * 2

def wrong : Int → Int := addOne ∘ double

#eval wrong 3
#guard wrong 3 == 8
