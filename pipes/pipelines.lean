def numbers : List Int := [1, 3, 5, 2, 8, 4, 7]

-- filter, then map, then fold
#eval numbers
  |> List.filter (· > 2)
  |> List.map (· * 3)
  |> List.filter (· < 20)
  |> List.foldl (· + ·) 0    -- use 0 as initial value
