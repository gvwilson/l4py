def numbers : List Int := [1, 3, 5, 7]

-- map transforms every element
#eval numbers.map (fun val => val * 2)

-- filter keeps only matching elements
#eval numbers.filter (fun val => val >= 5)

-- foldl accumulates from the left
#eval numbers.foldl (fun left right => left + right) 0
