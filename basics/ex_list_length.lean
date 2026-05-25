-- Write a function 'myLength' that returns the length of a List Int
-- using recursion. Do not use List.length.
def myLength (xs : List Int) : Nat :=
  0

#guard myLength [] == 0
#guard myLength [1, 2, 3] == 3
#guard myLength [5] == 1
