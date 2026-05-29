-- Write a function that computes throughput: items consumed per unit of simulation time
def lcgA : Nat := 1664525
def lcgC : Nat := 1013904223
def lcgM : Nat := 4294967296

def nextSeed (seed : Nat) : Nat := (lcgA * seed + lcgC) % lcgM

def expVariate (seed : Nat) (lambda : Float) : Float × Nat :=
  let s := nextSeed seed
  let u := (s.toFloat + 1.0) / (lcgM.toFloat + 1.0)
  (-Float.log u / lambda, s)

inductive Event where
  | Produce : Float → Nat → Event
  | Consume : Float → Nat → Event

def eventTime : Event → Float
  | .Produce t _ => t
  | .Consume t _ => t

def schedule (evs : List Event) (e : Event) : List Event :=
  match evs with
  | [] => [e]
  | h :: t =>
    if eventTime e <= eventTime h then e :: h :: t
    else h :: schedule t e

structure Params where
  numProducers : Nat
  numConsumers : Nat
  capacity     : Nat
  lambdaP      : Float
  lambdaC      : Float
  seed         : Nat

structure SimState where
  time             : Float
  queueSize        : Nat
  waitingProducers : List Nat
  waitingConsumers : List Nat
  events           : List Event
  totalProduced    : Nat
  totalConsumed    : Nat

def handleProduce (p : Params) (s : SimState) (t : Float) (pid : Nat) (seed : Nat)
    : SimState × Nat :=
  if s.queueSize < p.capacity then
    let (dt, seed') := expVariate seed p.lambdaP
    let evs := schedule s.events (Event.Produce (t + dt) pid)
    let (evs', remCons) :=
      if s.queueSize == 0
      then (s.waitingConsumers.foldl (fun e cid => schedule e (Event.Consume t cid)) evs, [])
      else (evs, s.waitingConsumers)
    ({ s with time := t, queueSize := s.queueSize + 1,
              waitingConsumers := remCons, events := evs',
              totalProduced := s.totalProduced + 1 }, seed')
  else
    ({ s with time := t, waitingProducers := s.waitingProducers ++ [pid] }, seed)

def handleConsume (p : Params) (s : SimState) (t : Float) (cid : Nat) (seed : Nat)
    : SimState × Nat :=
  if s.queueSize > 0 then
    let (dt, seed') := expVariate seed p.lambdaC
    let evs := schedule s.events (Event.Consume (t + dt) cid)
    let (evs', remProds) :=
      if s.queueSize == 1
      then (s.waitingProducers.foldl (fun e pid => schedule e (Event.Produce t pid)) evs, [])
      else (evs, s.waitingProducers)
    ({ s with time := t, queueSize := s.queueSize - 1,
              waitingProducers := remProds, events := evs',
              totalConsumed := s.totalConsumed + 1 }, seed')
  else
    ({ s with time := t, waitingConsumers := s.waitingConsumers ++ [cid] }, seed)

def stepSim (p : Params) (s : SimState) (seed : Nat) : Option (SimState × Nat) :=
  match s.events with
  | []     => none
  | e :: rest =>
    let s' := { s with events := rest }
    match e with
    | .Produce t pid => some (handleProduce p s' t pid seed)
    | .Consume t cid => some (handleConsume p s' t cid seed)

def initSim (p : Params) (seed : Nat) : SimState × Nat :=
  let (evs1, s1) := List.range p.numProducers |>.foldl
    (fun (acc : List Event × Nat) pid =>
      let (evs, s) := acc
      let (dt, s') := expVariate s p.lambdaP
      (schedule evs (Event.Produce dt pid), s'))
    ([], seed)
  let (evs2, s2) := List.range p.numConsumers |>.foldl
    (fun (acc : List Event × Nat) cid =>
      let (evs, s) := acc
      let (dt, s') := expVariate s p.lambdaC
      (schedule evs (Event.Consume dt cid), s'))
    (evs1, s1)
  ({ time := 0, queueSize := 0, waitingProducers := [], waitingConsumers := [],
     events := evs2, totalProduced := 0, totalConsumed := 0 }, s2)

def runLoop : Params → SimState → Nat → Nat → SimState
  | _, s, 0,     _ => s
  | p, s, n + 1, seed =>
    match stepSim p s seed with
    | none           => s
    | some (s', sd') => runLoop p s' n sd'

def runSim (p : Params) (n : Nat) : SimState :=
  let (s0, s1) := initSim p p.seed
  runLoop p s0 n s1

-- Write throughput: items consumed per unit simulation time
-- Return 0.0 if simulation time is 0
def throughput (s : SimState) : Float :=
  0.0

#guard
  let p : Params := { numProducers := 2, numConsumers := 2,
                      capacity := 4, lambdaP := 1.0, lambdaC := 1.0, seed := 42 }
  let s := runSim p 500
  throughput s > 0.0

#guard
  let empty : SimState := { time := 0, queueSize := 0, waitingProducers := [],
                             waitingConsumers := [], events := [],
                             totalProduced := 0, totalConsumed := 0 }
  throughput empty == 0.0
