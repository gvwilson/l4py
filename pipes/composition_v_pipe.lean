def double (x : Int) : Int := x * 2
def addOne (x : Int) : Int := x + 1

-- pipe: apply functions to a value
#eval 3 |> addOne |> double

-- composition: combine functions without a value
def addThenDouble : Int → Int := double ∘ addOne
#eval addThenDouble 3
