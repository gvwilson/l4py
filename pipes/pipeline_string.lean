-- pipelines work with strings too
def words : List String := ["hello", "world", "from", "lean"]

#eval words
  |> List.filter (fun w => w.length > 4)
  |> List.map String.toUpper
  |> String.intercalate " | "
