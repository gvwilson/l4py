-- |> works with anonymous functions too
def numbers : List Int := [1, 2, 3, 4, 5]

#eval numbers
  |> List.map (· * 2)
  |> List.filter (· > 5)
