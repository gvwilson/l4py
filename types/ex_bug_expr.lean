-- This eval function should handle all expression types,
-- but the mul case is missing. Fix it.
inductive Expr where
  | num (n : Int)
  | add (left : Expr) (right : Expr)
  | mul (left : Expr) (right : Expr)

def eval : Expr → Int
  | Expr.num n => n
  | Expr.add l r => eval l + eval r
