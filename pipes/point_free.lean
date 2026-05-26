def double (x : Int) : Int := x * 2
def addOne (x : Int) : Int := x + 1

-- point-ful: the argument is named explicitly
def doubleAfterAdd (x : Int) : Int := double (addOne x)

-- point-free: the argument is never mentioned
def doubleAfterAddPF : Int → Int := double ∘ addOne

#eval doubleAfterAdd 3
#eval doubleAfterAddPF 3

-- point-free with anonymous functions
def squareAll : List Int → List Int := List.map (· ^ 2)
#eval squareAll [1, 2, 3]
