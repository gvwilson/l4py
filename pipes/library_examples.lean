-- List has many useful functions in the prelude
def nums : List Int := [10, 20, 30, 40, 50]

-- take first n elements
#eval nums.take 3

-- drop first n elements
#eval nums.drop 2

-- range from 0 to n-1
#eval List.range 5

-- zip two lists together
#eval List.zip [1, 2, 3] ["a", "b", "c"]

-- use them in a pipeline
#eval List.range 10
  |> List.filter (· % 3 == 0)
  |> List.map (· * 10)
