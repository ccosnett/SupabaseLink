(* ::Package:: *)

(* SupabaseLink - Wolfram Language interface to Supabase via PostgREST *)
(* Modeled after https://github.com/chriswolfram/OpenAILink             *)

BeginPackage["SupabaseLink`"]

(* ------------------------------------------------------------------ *)
(* Public symbol declarations                                          *)
(* ------------------------------------------------------------------ *)

$SupabaseURL::usage = "$SupabaseURL is the base URL of the Supabase project."

$SupabaseAPIKey::usage = "$SupabaseAPIKey is the project API key (anon or service_role)."

SupabaseConnect::usage = "SupabaseConnect[url, apiKey] configures the connection credentials."

SupabaseSelect::usage =
    "SupabaseSelect[table] returns all rows from table as a Dataset.\n" <>
    "SupabaseSelect[table, filters] returns filtered rows."

SupabaseInsert::usage = "SupabaseInsert[table, data] inserts one or more rows into table."

SupabaseUpdate::usage = "SupabaseUpdate[table, data, filters] updates rows matching filters."

SupabaseDelete::usage = "SupabaseDelete[table, filters] deletes rows matching filters."

SupabaseRPC::usage =
    "SupabaseRPC[function] calls a Supabase database function.\n" <>
    "SupabaseRPC[function, params] calls the function with the given parameters."

(* ------------------------------------------------------------------ *)
(* Private context                                                     *)
(* ------------------------------------------------------------------ *)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* $SupabaseURL and $SupabaseAPIKey                                    *)
(* ------------------------------------------------------------------ *)

$SupabaseURL = None
$SupabaseAPIKey = None

(* ------------------------------------------------------------------ *)
(* SupabaseConnect                                                     *)
(*                                                                     *)
(* Supabase projects expose a PostgREST endpoint at                   *)
(*   https://<project-ref>.supabase.co/rest/v1/                       *)
(* Authentication requires two headers on every request:              *)
(*   apikey: <anon-or-service-role-key>                               *)
(*   Authorization: Bearer <anon-or-service-role-key>                 *)
(* ------------------------------------------------------------------ *)

SupabaseConnect[url_String, apiKey_String] :=
    Module[{trimmedURL},
        trimmedURL = StringTrimRight[url, "/"];
        $SupabaseURL    = trimmedURL;
        $SupabaseAPIKey = apiKey;
        Dataset[<|
            "URL"       -> trimmedURL,
            "Connected" -> True
        |>]
    ]

(* ------------------------------------------------------------------ *)
(* Internal HTTP request helper                                        *)
(* ------------------------------------------------------------------ *)

(* Returns base authentication headers required by every PostgREST call *)
iAuthHeaders[] := {
    "apikey"        -> $SupabaseAPIKey,
    "Authorization" -> "Bearer " <> $SupabaseAPIKey,
    "Content-Type"  -> "application/json",
    "Accept"        -> "application/json"
}

(* Build a query string from an Association of equality filters.
   Supabase PostgREST filter syntax: ?col=eq.value              *)
iQueryString[filters_Association] :=
    If[Length[filters] === 0,
        "",
        "?" <> StringRiffle[
            KeyValueMap[
                URLEncode[#1] <> "=eq." <> URLEncode[ToString[#2]] &,
                filters
            ],
            "&"
        ]
    ]

iQueryString[None] := ""

(* Core HTTP dispatch.  Returns parsed WL expression or Failure. *)
iRequest[method_String, table_String,
         body    : (_String | None)       : None,
         filters : (_Association | None)  : None,
         prefer  : _String                : ""] :=
    Module[{url, headers, bodyRule, req, resp},
        url     = $SupabaseURL <> "/rest/v1/" <> table <> iQueryString[filters];
        headers = Join[
            iAuthHeaders[],
            If[prefer =!= "", {"Prefer" -> prefer}, {}]
        ];
        bodyRule = If[body =!= None, "Body" -> body, Nothing];
        req  = HTTPRequest[url, <|"Method" -> method, "Headers" -> headers, bodyRule|>];
        resp = URLRead[req];
        Which[
            resp["StatusCode"] >= 400,
                Failure["SupabaseError", <|
                    "MessageTemplate"  -> "HTTP `1`: `2`",
                    "MessageParameters" -> {resp["StatusCode"], resp["Body"]}
                |>],
            resp["Body"] === "" || resp["Body"] === "null",
                Nothing,
            True,
                ImportString[resp["Body"], "RawJSON"]
        ]
    ]

(* ------------------------------------------------------------------ *)
(* SupabaseSelect                                                      *)
(* ------------------------------------------------------------------ *)

SupabaseSelect[table_String] :=
    SupabaseSelect[table, <||>]

SupabaseSelect[table_String, filters_Association] :=
    Module[{result},
        result = iRequest["GET", table, None, filters];
        If[FailureQ[result], result, Dataset[result]]
    ]

(* ------------------------------------------------------------------ *)
(* SupabaseInsert                                                      *)
(* ------------------------------------------------------------------ *)

SupabaseInsert[table_String, data_Association] :=
    SupabaseInsert[table, {data}]

SupabaseInsert[table_String, data : {__Association}] :=
    Module[{json, result},
        json   = ExportString[data, "JSON"];
        result = iRequest["POST", table, json, None, "return=representation"];
        If[FailureQ[result], result, Dataset[result]]
    ]

(* ------------------------------------------------------------------ *)
(* SupabaseUpdate                                                      *)
(* ------------------------------------------------------------------ *)

SupabaseUpdate[table_String, data_Association, filters_Association] :=
    Module[{json, result},
        json   = ExportString[data, "JSON"];
        result = iRequest["PATCH", table, json, filters, "return=representation"];
        If[FailureQ[result], result, Dataset[result]]
    ]

(* ------------------------------------------------------------------ *)
(* SupabaseDelete                                                      *)
(* ------------------------------------------------------------------ *)

SupabaseDelete[table_String, filters_Association] :=
    Module[{result},
        result = iRequest["DELETE", table, None, filters, "return=representation"];
        If[FailureQ[result], result, Dataset[result]]
    ]

(* ------------------------------------------------------------------ *)
(* SupabaseRPC                                                         *)
(* ------------------------------------------------------------------ *)

SupabaseRPC[function_String] :=
    SupabaseRPC[function, <||>]

SupabaseRPC[function_String, params_Association] :=
    Module[{json, result},
        json   = ExportString[params, "JSON"];
        result = iRequest["POST", "rpc/" <> function, json];
        If[FailureQ[result], result, result]
    ]

End[] (* SupabaseLink`Private` *)

EndPackage[] (* SupabaseLink` *)
