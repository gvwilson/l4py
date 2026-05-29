import Lean
open Lean

-- mccole: rng
-- Linear congruential generator constants from Numerical Recipes
def lcgA : Nat := 1664525
def lcgC : Nat := 1013904223
def lcgM : Nat := 4294967296  -- 2^32

def nextSeed (seed : Nat) : Nat :=
  (lcgA * seed + lcgC) % lcgM

-- Sample from Exp(lambda): X = -ln(U) / lambda via the inverse-CDF method
def expVariate (seed : Nat) (lambda : Float) : Float × Nat :=
  let s := nextSeed seed
  -- shift numerator so u is in (0, 1), never exactly 0
  let u := (s.toFloat + 1.0) / (lcgM.toFloat + 1.0)
  (-Float.log u / lambda, s)
-- mccole: /rng

-- mccole: event
-- Each event records when it fires and which agent fires it
inductive Event where
  | Produce : Float → Nat → Event  -- (time, producer-id)
  | Consume : Float → Nat → Event  -- (time, consumer-id)

def eventTime : Event → Float
  | .Produce t _ => t
  | .Consume t _ => t
-- mccole: /event

-- mccole: state
-- Simulation parameters
structure Params where
  numProducers : Nat
  numConsumers : Nat
  capacity     : Nat
  lambdaP      : Float  -- producer inter-arrival rate
  lambdaC      : Float  -- consumer inter-arrival rate
  seed         : Nat

-- All simulation state threaded through the event loop
structure SimState where
  time             : Float
  queueSize        : Nat
  waitingProducers : List Nat   -- producer ids blocked on a full queue
  waitingConsumers : List Nat   -- consumer ids blocked on an empty queue
  events           : List Event -- pending events, sorted earliest-first
  totalProduced    : Nat
  totalConsumed    : Nat
-- mccole: /state

-- mccole: schedule
-- Insert one event into a time-sorted list (earliest event first)
def schedule (evs : List Event) (e : Event) : List Event :=
  match evs with
  | []     => [e]
  | h :: t =>
    if eventTime e <= eventTime h then e :: h :: t
    else h :: schedule t e
-- mccole: /schedule

-- mccole: handle-produce
-- A producer tries to add an item to the bounded queue
def handleProduce (p : Params) (s : SimState) (t : Float) (pid : Nat) (seed : Nat)
    : SimState × Nat :=
  if s.queueSize < p.capacity then
    -- Space available: deposit the item and reschedule this producer
    let (dt, seed') := expVariate seed p.lambdaP
    let evs := schedule s.events (Event.Produce (t + dt) pid)
    -- Queue was empty: wake every consumer that was blocked waiting for an item
    let (evs', remCons) :=
      if s.queueSize == 0
      then (s.waitingConsumers.foldl (fun e cid => schedule e (Event.Consume t cid)) evs, [])
      else (evs, s.waitingConsumers)
    ({ s with time := t, queueSize := s.queueSize + 1,
              waitingConsumers := remCons, events := evs',
              totalProduced := s.totalProduced + 1 }, seed')
  else
    -- Queue full: block this producer until the queue drains to empty
    ({ s with time := t,
              waitingProducers := s.waitingProducers ++ [pid] }, seed)
-- mccole: /handle-produce

-- mccole: handle-consume
-- A consumer tries to take an item from the bounded queue
def handleConsume (p : Params) (s : SimState) (t : Float) (cid : Nat) (seed : Nat)
    : SimState × Nat :=
  if s.queueSize > 0 then
    -- Item available: take it and reschedule this consumer
    let (dt, seed') := expVariate seed p.lambdaC
    let evs := schedule s.events (Event.Consume (t + dt) cid)
    -- Queue just drained: wake every producer that was blocked waiting for space
    let (evs', remProds) :=
      if s.queueSize == 1
      then (s.waitingProducers.foldl (fun e pid => schedule e (Event.Produce t pid)) evs, [])
      else (evs, s.waitingProducers)
    ({ s with time := t, queueSize := s.queueSize - 1,
              waitingProducers := remProds, events := evs',
              totalConsumed := s.totalConsumed + 1 }, seed')
  else
    -- Queue empty: block this consumer until an item arrives
    ({ s with time := t,
              waitingConsumers := s.waitingConsumers ++ [cid] }, seed)
-- mccole: /handle-consume

-- mccole: step
-- Pop and dispatch the earliest event from the queue
def stepSim (p : Params) (s : SimState) (seed : Nat) : Option (SimState × Nat) :=
  match s.events with
  | []     => none
  | e :: rest =>
    let s' := { s with events := rest }
    match e with
    | .Produce t pid => some (handleProduce p s' t pid seed)
    | .Consume t cid => some (handleConsume p s' t cid seed)
-- mccole: /step

-- mccole: run
-- Schedule the first arrival for every producer and consumer
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

-- Run for exactly n events; structural recursion on n guarantees termination
def runLoop : Params → SimState → Nat → Nat → SimState
  | _, s, 0,     _ => s
  | p, s, n + 1, seed =>
    match stepSim p s seed with
    | none           => s
    | some (s', sd') => runLoop p s' n sd'

def runSim (p : Params) (numEvents : Nat) : SimState :=
  let (s0, s1) := initSim p p.seed
  runLoop p s0 numEvents s1
-- mccole: /run

-- mccole: tests
-- schedule keeps events in ascending time order
#guard
  let evs := schedule (schedule [] (Event.Produce 3.0 0)) (Event.Produce 1.0 1)
  evs.map eventTime == [1.0, 3.0]

-- expVariate always returns a positive inter-arrival time
#guard (expVariate 0    1.0).1 > 0.0
#guard (expVariate 42   2.5).1 > 0.0
#guard (expVariate 9999 0.5).1 > 0.0

-- a balanced simulation produces and consumes items
#guard
  let p : Params := { numProducers := 2, numConsumers := 2,
                      capacity := 4, lambdaP := 1.0, lambdaC := 1.0, seed := 42 }
  let s := runSim p 200
  s.totalProduced > 0 && s.totalConsumed > 0

-- items are conserved: produced = consumed + items still in queue
#guard
  let p : Params := { numProducers := 3, numConsumers := 2,
                      capacity := 5, lambdaP := 1.0, lambdaC := 1.5, seed := 99 }
  let s := runSim p 500
  s.totalProduced == s.totalConsumed + s.queueSize

-- queue size never exceeds capacity
#guard
  let p : Params := { numProducers := 5, numConsumers := 1,
                      capacity := 3, lambdaP := 5.0, lambdaC := 0.5, seed := 7 }
  let s := runSim p 300
  s.queueSize ≤ p.capacity
-- mccole: /tests

-- mccole: parse
-- Parse a non-negative decimal string such as "1" or "1.5" into a Float
def parseFloat (s : String) : Option Float :=
  match s.splitOn "." with
  | [whole]       => whole.toNat?.map Float.ofNat
  | [whole, frac] =>
    match (whole.toNat?, frac.toNat?) with
    | (some w, some f) =>
      let denom := Float.ofNat (10 ^ frac.length)
      some (Float.ofNat w + Float.ofNat f / denom)
    | _ => none
  | _ => none
-- mccole: /parse

-- mccole: json
-- Parse all six parameters from a JSON object string using Lean.Data.Json
def parseJson (json : String) : Option Params := do
  let j    ← (Json.parse json).toOption
  let numP ← (j.getObjValAs? Nat   "P").toOption
  let numC ← (j.getObjValAs? Nat   "C").toOption
  let cap  ← (j.getObjValAs? Nat   "N").toOption
  let lp   ← (j.getObjValAs? Float "lambda_p").toOption
  let lc   ← (j.getObjValAs? Float "lambda_c").toOption
  let sd   ← (j.getObjValAs? Nat   "seed").toOption
  some { numProducers := numP, numConsumers := numC, capacity := cap,
         lambdaP := lp, lambdaC := lc, seed := sd }
-- mccole: /json

-- mccole: main
def printResults (p : Params) (s : SimState) (numEvents : Nat) : IO Unit := do
  IO.println s!"producers={p.numProducers}  consumers={p.numConsumers}  capacity={p.capacity}"
  IO.println s!"lambda_p={p.lambdaP}  lambda_c={p.lambdaC}  seed={p.seed}"
  IO.println s!"events processed : {numEvents}"
  IO.println s!"total produced   : {s.totalProduced}"
  IO.println s!"total consumed   : {s.totalConsumed}"
  IO.println s!"final queue size : {s.queueSize}"
  IO.println s!"blocked producers: {s.waitingProducers.length}"
  IO.println s!"blocked consumers: {s.waitingConsumers.length}"
  IO.println s!"simulation time  : {s.time}"

def main (args : List String) : IO Unit := do
  let numEvents := 10000
  match args with
  | [path] =>
    -- single argument: read parameters from a JSON file
    let json ← IO.FS.readFile path
    match parseJson json with
    | none   => IO.eprintln s!"error: could not parse parameters from {path}"
    | some p => printResults p (runSim p numEvents) numEvents
  | [sP, sC, sN, sLp, sLc, sSeed] =>
    -- six arguments: P C N lambda_p lambda_c seed
    let p : Params := {
      numProducers := sP.toNat?.getD 1,
      numConsumers := sC.toNat?.getD 1,
      capacity     := sN.toNat?.getD 1,
      lambdaP      := (parseFloat sLp).getD 1.0,
      lambdaC      := (parseFloat sLc).getD 1.0,
      seed         := sSeed.toNat?.getD 0
    }
    printResults p (runSim p numEvents) numEvents
  | _ =>
    IO.eprintln "usage: des P C N lambda_p lambda_c seed"
    IO.eprintln "       des params.json"
-- mccole: /main
