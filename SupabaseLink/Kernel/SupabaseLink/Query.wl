(* ::Package:: *)

(* SupabaseLink/Query.wl
   Read-only operations: SELECT and RPC calls.
   Loaded by Kernel/SupabaseLink.wl.
*)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* Internal helpers                                                     *)
(* ------------------------------------------------------------------ *)

(* iFiltersToQueryString[filters]
   Convert an Association or list of rules to a URL query string.
   PostgREST uses equality filters as   ?col=eq.value
   e.g. {"status" -> "active", "id" -> 42}
        => "?status=eq.active&id=eq.42"

   TODO: extend for richer operators: neq, lt, gt, like, in, etc.
*)
iFiltersToQueryString[filters_Association] :=
  "?" <> StringRiffle[
    KeyValueMap[
      Function[{k, v}, URLEncode[k] <> "=eq." <> URLEncode[ToString[v]]],
      filters
    ],
    "&"
  ]

iFiltersToQueryString[filters_List] :=
  iFiltersToQueryString[Association[filters]]

iFiltersToQueryString[{}] := ""
iFiltersToQueryString[<||>] := ""

(* ------------------------------------------------------------------ *)
(* SupabaseSelect                                                       *)
(* ------------------------------------------------------------------ *)

(* Return all rows from table as a Dataset *)
SupabaseSelect[table_String] :=
  SupabaseSelect[table, <||>]

(* Return rows matching equality filters as a Dataset.
   filters: Association  e.g. <|"status" -> "active"|>
            or List       e.g. {"status" -> "active"}
   TODO: add column selection, ordering, pagination, range headers    *)
SupabaseSelect[table_String, filters_] :=
  Module[{path, rows},
    path = "/rest/v1/" <> table <> iFiltersToQueryString[filters];
    (* Gate through the Seven Samurai rate limiter *)
    rows = WithRateLimit[iRequest["GET", path, None]];
    (* TODO: convert keys to symbols / handle nested objects          *)
    Dataset[rows]
  ]

(* ------------------------------------------------------------------ *)
(* SupabaseRPC                                                          *)
(* ------------------------------------------------------------------ *)

(* Call a Supabase Postgres function with no arguments *)
SupabaseRPC[function_String] :=
  SupabaseRPC[function, <||>]

(* Call a Supabase Postgres function with an Association of params.
   The function must be defined in the "public" schema and exposed via
   PostgREST.
   TODO: support schema override via options                           *)
SupabaseRPC[function_String, params_Association] :=
  Module[{path, result},
    path   = "/rest/v1/rpc/" <> function;
    result = WithRateLimit[iRequest["POST", path, params]];
    result
  ]

End[] (* SupabaseLink`Private` *)
