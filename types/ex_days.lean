-- Write a function 'isWeekend' that returns true for Saturday and Sunday.
inductive Day where
  | monday | tuesday | wednesday | thursday | friday | saturday | sunday
deriving BEq, Repr

def isWeekend (d : Day) : Bool :=
  false

#guard isWeekend Day.saturday == true
#guard isWeekend Day.sunday == true
#guard isWeekend Day.monday == false
