-- Write 'safeDiv' that returns an Option Int:
-- Option.some of the quotient if b ≠ 0, Option.none otherwise.
def safeDiv (a : Int) (b : Int) : Option Int :=
  Option.none

#guard safeDiv 10 2 == Option.some 5
#guard safeDiv 10 0 == Option.none
#guard safeDiv 0 5 == Option.some 0
