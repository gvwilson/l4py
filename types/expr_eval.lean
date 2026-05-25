-- A tiny expression language: numbers, addition, multiplication
inductive Expr where
  | num (n : Int)
  | add (left : Expr) (right : Expr)
  | mul (left : Expr) (right : Expr)
deriving Repr

-- Evaluate an expression by recursing on its structure
def eval : Expr → Int
  | Expr.num n => n
  | Expr.add l r => eval l + eval r
  | Expr.mul l r => eval l * eval r

def e : Expr := Expr.add (Expr.num 3) (Expr.mul (Expr.num 4) (Expr.num 5))
#eval e
#eval eval e
