-- schedule inserts events in reverse time order; fix the comparison
inductive Event where
  | Produce : Float → Nat → Event
  | Consume : Float → Nat → Event

def eventTime : Event → Float
  | .Produce t _ => t
  | .Consume t _ => t

def schedule (evs : List Event) (e : Event) : List Event :=
  match evs with
  | []     => [e]
  | h :: t =>
    if eventTime e >= eventTime h  -- BUG: should be <=
    then e :: h :: t
    else h :: schedule t e

#guard
  let evs := schedule (schedule [] (Event.Produce 3.0 0)) (Event.Produce 1.0 1)
  evs.map eventTime == [1.0, 3.0]

#guard
  let evs := schedule (schedule (schedule [] (Event.Consume 5.0 0))
                                            (Event.Consume 2.0 1))
                                            (Event.Consume 4.0 2)
  evs.map eventTime == [2.0, 4.0, 5.0]
