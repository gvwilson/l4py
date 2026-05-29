# Discrete Event Simulation

<div class="callout" markdown="1">

-   Model concurrent agents as time-ordered events
-   Thread all state through a purely functional event loop, avoiding mutation
-   Use the inverse-CDF method to sample exponential inter-arrival times from a LCG
-   Parse parameters from command-line arguments or a JSON configuration file

</div>

-   A [%g des "discrete event simulation" %] advances time by jumping from one event to the next
    -   No fixed time step: time skips forward to whatever happens next
    -   Like an agenda that only records appointments, not empty minutes
-   We model P producers depositing items into a shared queue and C consumers taking them out
    -   Queue capacity N bounds how many items can wait at once
    -   Producers block when the queue is full; consumers block when it is empty
-   Every component is a pure function: easy to test with `#guard`

## Random Numbers

[%inc code.lean mark=rng %]

-   A [%g lcg "linear congruential generator" %] (LCG) advances a seed
    -   `seed' = (A &times; seed + C) mod M`
    -   The constants A, C, M are from [%b Press2007 %]; they pass standard randomness tests
    -   The same seed always produces the same sequence — reproducible simulations
-   `expVariate` converts a uniform sample U into an exponential variate `X = -ln(U) / λ`
    -   This is the [%g inverse_cdf "inverse-CDF method" %]:
	    if U ~ Uniform(0,1) then X ~ Exp(λ)
    -   Shifting the numerator by 1 keeps U strictly inside (0, 1) so logarithm is always defined
-   High λ = high rate = short inter-arrival times (like a busy coffee shop)
-   Like Python's `random.expovariate(λ)`

## Events and State

[%inc code.lean mark=event %]

[%inc code.lean mark=state %]

-   Each `Event` carries its firing time and the ID of the agent that fires it
    -   Two constructors: `Produce` and `Consume`
    -   `eventTime` extracts the time from either constructor
-   `Params` bundles all five simulation parameters together with the RNG seed
-   `SimState` records everything that changes as the simulation runs
    -   `waitingProducers` and `waitingConsumers` are the blocked agent queues
    -   `events` is the pending event list, kept sorted earliest-first

## Scheduling Events

[%inc code.lean mark=schedule %]

-   `schedule` inserts one event into a sorted list by walking the list until the right position
    -   O(n) per insertion; fine for teaching, but real system would use a heap
-   Ties are resolved by keeping the new event first (`<=`), which is arbitrary but consistent
-   Like Python's `bisect.insort` but on an immutable list instead of a mutable array

## Handling a Produce Event

[%inc code.lean mark=handle-produce %]

-   When a producer fires:
    -   If there is space (`queueSize < capacity`): deposit the item, schedule the next arrival
    -   If the queue was empty before depositing: wake every blocked consumer immediately
    -   If the queue is full: add this producer to `waitingProducers` without rescheduling it
-   "Blocking" in a DES means not scheduling the agent's next event until conditions change
-   Waking is done by inserting a `Consume` event at the current time `t` for each waiter

## Handling a Consume Event

[%inc code.lean mark=handle-consume %]

-   When a consumer fires:
    -   If there is an item (`queueSize > 0`): take it, schedule the next arrival
    -   If the queue just drained (`queueSize` went from 1 to 0): wake every blocked producer
    -   If the queue is empty: add this consumer to `waitingConsumers` without rescheduling it
-   The symmetric pair with `handleProduce`: full/empty are the two blocking conditions

## The Event Loop

[%inc code.lean mark=step %]

[%inc code.lean mark=run %]

-   `stepSim` pops the earliest event and dispatches it; returns `none` when no events remain
-   `initSim` seeds the simulation by scheduling one arrival for each producer and consumer
-   `runLoop` uses structural recursion on `n`: when `n` reaches zero the loop terminates
    -   Lean accepts this without a proof: the pattern `n + 1` guarantees n decreases
    -   DEBT: explain this more clearly
-   `runSim` packages `initSim` + `runLoop` into a single call

## Tests

[%inc code.lean mark=tests %]

-   `schedule` test: insert a later event then an earlier event; expect earliest-first order
-   `expVariate` tests: any seed and rate must produce a positive inter-arrival time
-   Conservation invariant: every item produced is either in the queue or has been consumed
-   Capacity invariant: queue size never exceeds the declared capacity

## Parsing Input

[%inc code.lean mark=json %]

-   `parseJson` uses `Json.parse` from `Lean.Data.Json` to parse the file contents
    -   `getObjValAs? Nat "P"` extracts field `"P"` and converts it to `Nat`
    -   `getObjValAs? Float "lambda_p"` extracts `"lambda_p"` and converts it to `Float`
    -   Both return `Except String α`; `.toOption` converts errors to `none`
-   Chaining six `←` binds inside a `do` block for `Option`: any missing field short-circuits to `none`
-   Like Python's `json.loads(text)["P"]` but with explicit `None`-propagation at every step

## Running the Program

[%inc code.lean mark=main %]

[%inc code.out %]

-   `main` accepts two call styles:
    -   Six arguments: `P C N lambda_p lambda_c seed` — one value per parameter
    -   One argument: a path to a JSON file containing the same six fields
-   The separator line `---` in the output separates the two modes shown by the script
-   Run with:
    -   `lake env lean --run des/code.lean 2 3 5 1.0 1.5 20240101`
    -   `lake env lean --run des/code.lean des/params.json`

<div class="exercise" markdown="1">

## Exercises

### Fix: Events Inserted in Wrong Order

[%inc ex_bug_des_order.lean %]

<details markdown="1"><summary>hint</summary>

-   `schedule` inserts a new event before `h` when the comparison is true
-   With `>=`, a later event is placed before an earlier one — reversing the sort order
-   Change `>=` to `<=` so earlier events come first

</details>

### Fix: Queue Exceeds Capacity

[%inc ex_bug_des_full.lean %]

<details markdown="1"><summary>hint</summary>

-   `handleProduce` should add to the queue only when there is space (`queueSize < capacity`)
-   With `<=`, a producer adds even when the queue is already at capacity, making it one over
-   Change `<=` to `<`

</details>

### Fix: Blocked Consumers Never Wake

[%inc ex_bug_des_wake_cons.lean %]

<details markdown="1"><summary>hint</summary>

-   When a producer deposits the first item into an empty queue, every blocked consumer should be rescheduled at the current time
-   The bug discards the wakeup logic and leaves `waitingConsumers` unchanged
-   Add: `if s.queueSize == 0 then (wake all in s.waitingConsumers, []) else (evs, s.waitingConsumers)`

</details>

### Fix: Blocked Producers Never Wake

[%inc ex_bug_des_wake_prod.lean %]

<details markdown="1"><summary>hint</summary>

-   When a consumer takes the last item from the queue, every blocked producer should be rescheduled at the current time
-   The bug leaves `waitingProducers` unchanged after the queue drains
-   Add: `if s.queueSize == 1 then (wake all in s.waitingProducers, []) else (evs, s.waitingProducers)`

</details>

### Write: Throughput

[%inc ex_des_throughput.lean %]

<details markdown="1"><summary>hint</summary>

-   Throughput is items consumed divided by total simulation time
-   Guard against division by zero when `time == 0`
-   Use `Float.ofNat s.totalConsumed / s.time`

</details>

### Write: Conservation Check

[%inc ex_des_conservation.lean %]

<details markdown="1"><summary>hint</summary>

-   Every item produced is either waiting in the queue or has already been consumed
-   The invariant is `totalProduced == totalConsumed + queueSize`
-   Return `s.totalProduced == s.totalConsumed + s.queueSize`

</details>

### Fix: Step Counter Runs Extra Loop

[%inc ex_bug_des_steps.lean %]

<details markdown="1"><summary>hint</summary>

-   The `runLoop` base case `0` still calls `stepSim` instead of returning `s`
-   When `n` is 0, the loop should stop immediately — not run one more step
-   Change the `0` case to just `| p, s, 0, _ => s`

</details>

### Write: Average Queue Size

[%inc ex_des_avg_queue.lean %]

<details markdown="1"><summary>hint</summary>

-   Average queue size is `totalConsumed / simulation time` for a naive approximation
-   Guard against division by zero: if `s.time == 0`, return `0.0`
-   Use `Float.ofNat s.totalConsumed / s.time`

</details>

### Write: Maximum Queue Size

[%inc ex_des_max_queue.lean %]

<details markdown="1"><summary>hint</summary>

-   The maximum queue size is at least the final queue size
-   Since we don't track the peak in this simplified struct, return `max s.queueSize (s.totalProduced - s.totalConsumed)`
-   Use `Nat.max` to compare two `Nat` values

</details>

### Write: Queue Utilization

[%inc ex_des_utilization.lean %]

<details markdown="1"><summary>hint</summary>

-   Utilization is the fraction of capacity in use: `queueSize / capacity`
-   Guard against zero capacity: `if capacity == 0 then 0.0 else Float.ofNat s.queueSize / Float.ofNat capacity`
-   The `#guard` expects exact floating-point values, so use `Float.ofNat` for the conversion

</details>

</div>
