-- Fix: this pipeline is missing a step
-- it should double numbers, keep even results, then sum them
#eval [1, 2, 3, 4, 5]
  |> List.map (· * 2)
  |> List.foldl (· + ·) 0
