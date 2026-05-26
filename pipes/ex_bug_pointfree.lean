-- Fix: the · placeholder usage is wrong
-- used as subtract-from: but there are two placeholders for a one-arg function
def numbers : List Int := [5, 10, 15]

-- (· - 2) subtracts 2 from each; (· - ·) is a two-argument function
def subtractAll : List Int := numbers |> List.map (· - ·)
