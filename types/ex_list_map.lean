-- Write 'myMap' that works like List.map, but using the inductive
-- List constructors directly (List.nil and List.cons) instead of
-- the [] and :: shorthand. This reveals what's really happening.
def myMap (f : α → β) (xs : List α) : List β :=
  []

#guard myMap (fun x => x + 1) [] == []
#guard myMap (fun x => x + 1) [1, 2, 3] == [2, 3, 4]
