-- pipeline: a chain of |> operations
-- like Python: [x for x in data if ...] with transformations

def numbers : List Int := [1, 3, 5, 2, 8, 4, 7]

-- filter, then map, then fold — in one pipeline
#eval numbers
  |> List.filter (· > 2)
  |> List.map (· * 3)
  |> List.filter (· < 20)
  |> List.foldl (· + ·) 0

-- same computation as a pipeline of partial results
def step1 : List Int := List.filter (· > 2) numbers
def step2 : List Int := List.map (· * 3) step1
def step3 : List Int := List.filter (· < 20) step2
def result : Int := List.foldl (· + ·) 0 step3

#eval result
