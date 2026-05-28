-- Except carries either a success value or an error message
def safeDivide (a b : Int) : Except String Int :=
  if b == 0 then Except.error "division by zero"
  else Except.ok (a / b)

#eval match safeDivide 10 2 with
  | Except.ok n    => s!"result: {n}"
  | Except.error e => s!"error: {e}"

#eval match safeDivide 10 0 with
  | Except.ok n    => s!"result: {n}"
  | Except.error e => s!"error: {e}"
