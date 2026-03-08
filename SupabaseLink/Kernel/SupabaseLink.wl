(* ::Package:: *)

(* SupabaseLink - Wolfram Language package for connecting to Supabase via PostgREST REST API *)
(* Modeled after https://github.com/chriswolfram/OpenAILink *)
(*
    "Seven Samurai" strategy: rate-limit outgoing requests so we never
    overwhelm the PostgREST gateway — only a controlled number of
    bandits enter the village at a time.
*)

BeginPackage["SupabaseLink`"]

(* ------------------------------------------------------------------ *)
(* Public symbol declarations — usage messages only, no definitions here *)
(* ------------------------------------------------------------------ *)

$SupabaseURL::usage =
    "$SupabaseURL is the base URL of your Supabase project (e.g. \"https://<ref>.supabase.co\")."

$SupabaseAPIKey::usage =
    "$SupabaseAPIKey is the anon or service_role API key for authenticating with Supabase."

$SupabaseMaxConcurrent::usage =
    "$SupabaseMaxConcurrent controls the maximum number of simultaneous requests \
sent to the PostgREST endpoint (the Seven Samurai gate). Default: 3."

SupabaseConnect::usage =
    "SupabaseConnect[url, apiKey] configures $SupabaseURL and $SupabaseAPIKey."

SupabaseSelect::usage =
    "SupabaseSelect[table] returns all rows from table as a Dataset.\n\
SupabaseSelect[table, filters] returns rows matching the given Association of filters."

SupabaseInsert::usage =
    "SupabaseInsert[table, data] inserts an Association or list of Associations into table."

SupabaseUpdate::usage =
    "SupabaseUpdate[table, data, filters] updates rows in table matching filters with data."

SupabaseDelete::usage =
    "SupabaseDelete[table, filters] deletes rows in table matching filters."

SupabaseRPC::usage =
    "SupabaseRPC[function] calls a Supabase database function (RPC).\n\
SupabaseRPC[function, params] calls the function with the given Association of parameters."

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* Internal helpers *)
(* ------------------------------------------------------------------ *)

(* TODO: implement a semaphore / task-queue using ParallelSubmit or
         a simple counter so that at most $SupabaseMaxConcurrent requests
         are in-flight at any time.  This is the "Seven Samurai gate". *)
iAcquireGate[] := Null   (* placeholder *)
iReleaseGate[] := Null   (* placeholder *)

(* Build the standard request headers from the configured credentials *)
iHeaders[] :=
    {
        "apikey"        -> $SupabaseAPIKey,
        "Authorization" -> "Bearer " <> $SupabaseAPIKey,
        "Content-Type"  -> "application/json",
        "Accept"        -> "application/json"
    }

(* Perform an HTTP request, respecting the concurrency gate *)
iRequest[method_, url_, opts___] :=
    Module[{response},
        iAcquireGate[];
        response = URLRead[HTTPRequest[url, <|"Method" -> method, "Headers" -> iHeaders[], opts|>]];
        iReleaseGate[];
        response
    ]

(* Parse a URLRead response body as JSON and wrap in Dataset *)
iParseResponse[response_] :=
    Module[{body = response["Body"]},
        If[StringQ[body] && body =!= "",
            Dataset[ImportString[body, "RawJSON"]],
            Missing["EmptyResponse"]
        ]
    ]

(* Build a PostgREST filter query string from an Association *)
iFilterQuery[filters_Association] :=
    StringRiffle[
        KeyValueMap[URLEncode[#1] <> "=eq." <> URLEncode[ToString[#2]] &, filters],
        "&"
    ]
iFilterQuery[{}] := ""
iFilterQuery[___] := ""

(* ------------------------------------------------------------------ *)
(* Configuration *)
(* ------------------------------------------------------------------ *)

$SupabaseURL = None
$SupabaseAPIKey = None
$SupabaseMaxConcurrent = 3   (* only 2-3 samurai guard the gate at once *)

SupabaseConnect[url_String, apiKey_String] :=
    ($SupabaseURL = url; $SupabaseAPIKey = apiKey; <|"URL" -> url|>)

(* ------------------------------------------------------------------ *)
(* CRUD operations *)
(* ------------------------------------------------------------------ *)

(* SELECT — no filters *)
SupabaseSelect[table_String] :=
    iParseResponse[
        iRequest["GET", $SupabaseURL <> "/rest/v1/" <> table]
    ]

(* SELECT — with filters *)
SupabaseSelect[table_String, filters_] :=
    Module[{qs = iFilterQuery[filters]},
        iParseResponse[
            iRequest["GET", $SupabaseURL <> "/rest/v1/" <> table <> If[qs =!= "", "?" <> qs, ""]]
        ]
    ]

(* INSERT *)
SupabaseInsert[table_String, data_] :=
    iParseResponse[
        iRequest["POST", $SupabaseURL <> "/rest/v1/" <> table,
            "Body" -> ExportString[data, "RawJSON"]]
    ]

(* UPDATE *)
SupabaseUpdate[table_String, data_Association, filters_] :=
    Module[{qs = iFilterQuery[filters]},
        iParseResponse[
            iRequest["PATCH", $SupabaseURL <> "/rest/v1/" <> table <> If[qs =!= "", "?" <> qs, ""],
                "Body" -> ExportString[data, "RawJSON"]]
        ]
    ]

(* DELETE *)
SupabaseDelete[table_String, filters_] :=
    Module[{qs = iFilterQuery[filters]},
        iParseResponse[
            iRequest["DELETE", $SupabaseURL <> "/rest/v1/" <> table <> If[qs =!= "", "?" <> qs, ""]]
        ]
    ]

(* RPC — no params *)
SupabaseRPC[function_String] :=
    iParseResponse[
        iRequest["POST", $SupabaseURL <> "/rest/v1/rpc/" <> function,
            "Body" -> "{}"]
    ]

(* RPC — with params *)
SupabaseRPC[function_String, params_Association] :=
    iParseResponse[
        iRequest["POST", $SupabaseURL <> "/rest/v1/rpc/" <> function,
            "Body" -> ExportString[params, "RawJSON"]]
    ]

End[]  (* SupabaseLink`Private` *)

EndPackage[]  (* SupabaseLink` *)
