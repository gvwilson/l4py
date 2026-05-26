-- Write: pipeline that selects words with more than 3 letters,
-- uppercases them, and joins with " + "
def words : List String := ["hi", "hello", "yo", "world", "a"]

#eval words
  |> List.filter (fun w => 0 == 0)  -- replace with real filter
  |> List.map (fun w => w)          -- replace with uppercase
  |> String.intercalate ""          -- replace with " + "
