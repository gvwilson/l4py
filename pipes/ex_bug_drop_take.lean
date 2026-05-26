-- Fix: drop and take are swapped — this discards the first 2 and keeps the rest
-- it should keep the first 2 and drop the rest
#eval List.range 5
  |> List.drop 2
  |> List.map (· * 10)
#guard (List.range 5 |> List.drop 2 |> List.map (· * 10)) == [0, 10]
