-- List is defined in the standard library as:
-- inductive List (α : Type) where
--   | nil : List α
--   | cons (head : α) (tail : List α) : List α

-- [] is shorthand for List.nil
-- head :: tail is shorthand for List.cons head tail

#check []
#check 1 :: [2, 3]
#check List.cons 1 (List.cons 2 (List.cons 3 List.nil))
