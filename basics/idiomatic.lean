def numbers : List Int := [1, 3, 5, 7]

-- use · shorthand for simple lambdas
#eval numbers.map (· * 2)

-- use mathematical symbols
#eval numbers.filter (· ≥ 5)

-- each · matches a parameter in order
#eval numbers.foldl (· + ·) 0
