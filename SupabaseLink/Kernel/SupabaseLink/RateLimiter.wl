(* ::Package:: *)

(* SupabaseLink/RateLimiter.wl

   The Seven Samurai Gate
   ~~~~~~~~~~~~~~~~~~~~~~
   In Kurosawa's "Seven Samurai" the villagers defend themselves by
   channelling the bandits through a narrow gate — only 2 or 3 can
   squeeze through at once, making them manageable.

   This file implements the same idea for HTTP requests to Supabase:
   instead of firing every request simultaneously (and tripping
   rate-limit errors or overwhelming the DB connection pool), we hold
   requests in a queue and only let $SupabaseConcurrency of them
   through the gate at any one time.

   Architecture sketch
   -------------------
     Queue            Gate (semaphore)         Supabase
     -----            ----------------         --------
     req1  -->  [slot 1 acquired]  ------>  POST /rest/v1/...
     req2  -->  [slot 2 acquired]  ------>  GET  /rest/v1/...
     req3  -->  [waiting ...]
     req4  -->  [waiting ...]
                [slot 1 released] --> req3 acquires

   Implementation notes
   --------------------
   Wolfram Language does not have built-in semaphore primitives, but we
   can emulate them with a combination of:
     - A shared counter protected by a named mutex via $ProcessID tricks,
       OR
     - ParallelSubmit / WaitAll with controlled Kernels (simplest for
       most use-cases).

   TODO: choose the right concurrency model for your environment:
     Option A  — Simple sequential queue (safest, lowest overhead).
                 Just map iRequest over inputs one at a time.
     Option B  — ParallelSubmit + WaitAll with LaunchKernels[$SupabaseConcurrency].
                 Good when requests are independent and latency matters.
     Option C  — Custom semaphore via $SharedVariables across subkernels.
                 Most flexible, most complexity.
   Currently Option A is stubbed below as the safe default.
*)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* Configuration                                                        *)
(* ------------------------------------------------------------------ *)

(* Maximum concurrent in-flight requests.
   Change to a higher number if your Supabase plan supports it and you
   have launched enough parallel kernels.                              *)
$SupabaseConcurrency = 3

(* ------------------------------------------------------------------ *)
(* Gate state  (Option A — sequential stub)                             *)
(* ------------------------------------------------------------------ *)

(* TODO: replace with a real semaphore when Option B/C is chosen *)
$iGateSlotsFree = $SupabaseConcurrency  (* bookkeeping only for now *)

(* ------------------------------------------------------------------ *)
(* WithRateLimit                                                        *)
(* ------------------------------------------------------------------ *)

(* WithRateLimit[expr]
   Evaluates expr after acquiring a gate slot, then releases the slot.

   Current behaviour: sequential pass-through (Option A stub).
   Swap the body for a semaphore acquire/release pair when you upgrade.
*)
WithRateLimit[expr_] :=
  Module[{result},
    iAcquireSlot[];               (* block until a slot is free *)
    result = expr;                (* evaluate the gated expression *)
    iReleaseSlot[];               (* free the slot for the next request *)
    result
  ]

(* ------------------------------------------------------------------ *)
(* Internal slot management  (stubs — replace per chosen option)       *)
(* ------------------------------------------------------------------ *)

(* iAcquireSlot[]
   Block the current kernel thread until a gate slot is available.
   TODO: implement — for Option A this is a no-op.                    *)
iAcquireSlot[] := Null  (* stub *)

(* iReleaseSlot[]
   Signal that the current request is done and a slot is now free.
   TODO: implement — for Option A this is a no-op.                    *)
iReleaseSlot[] := Null  (* stub *)

(* ------------------------------------------------------------------ *)
(* Batch helper                                                         *)
(* ------------------------------------------------------------------ *)

(* iBatch[requestFn, items, batchSize]
   Apply requestFn to each item in items, but send at most batchSize
   requests concurrently (the Seven Samurai batch gate).

   Example:
     iBatch[SupabaseInsert["orders", #]&, myRows, $SupabaseConcurrency]

   TODO: wire up real parallelism once Option B/C is implemented.
   For now this is a safe sequential Map.
*)
iBatch[requestFn_, items_List, batchSize_Integer : $SupabaseConcurrency] :=
  Module[{batches},
    (* Split items into chunks of batchSize *)
    batches = Partition[items, batchSize, batchSize, 1, {}];
    (* TODO: replace Map with ParallelMap / ParallelSubmit when ready *)
    Flatten[Map[Map[requestFn, #]&, batches], 1]
  ]

End[] (* SupabaseLink`Private` *)
