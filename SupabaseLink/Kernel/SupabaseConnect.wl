(* ::Package:: *)

BeginPackage["SupabaseLink`SupabaseConnect`"];
Unprotect["SupabaseLink`SupabaseConnect`*"]; ClearAll["SupabaseLink`SupabaseConnect`*"]; ClearAll["SupabaseLink`SupabaseConnect`Private`*"]; ClearSystemCache[];


(* Public symbol declarations *)
$SupabaseURL::usage = "$SupabaseURL is the base URL of the connected Supabase project.";
$SupabaseAPIKey::usage = "$SupabaseAPIKey is the API key used for Supabase requests.";

SupabaseConnect::usage =
    "SupabaseConnect[url, apiKey] stores the Supabase project URL and API key for subsequent requests " <>
    "and returns a Dataset confirming the connection.";

SupabaseSelect::usage =
    "SupabaseSelect[table] fetches all rows from table.\n" <>
    "SupabaseSelect[table, filters] fetches rows matching equality filters (an Association of column -> value).";

SupabaseInsert::usage =
    "SupabaseInsert[table, data] inserts one row (Association) or many rows ({Association..}) into table.";

SupabaseUpdate::usage =
    "SupabaseUpdate[table, data, filters] updates rows matching filters with the given data (Association).";

SupabaseDelete::usage =
    "SupabaseDelete[table, filters] deletes rows matching equality filters.";

SupabaseRPC::usage =
    "SupabaseRPC[fn] calls a Supabase database function.\n" <>
    "SupabaseRPC[fn, params] passes an Association of parameters.";


Get[FileNameJoin[{DirectoryName[$InputFileName], "LoadDotEnv.wl"}]];


Begin["`Private`"];
Needs["SupabaseLink`"];

(* ----- State ----- *)

$SupabaseURL = None;
$SupabaseAPIKey = None;


(* ----- HTTP helpers ----- *)

iHeaders[] := {
    "apikey" -> $SupabaseAPIKey,
    "Authorization" -> "Bearer " <> $SupabaseAPIKey,
    "Accept" -> "application/json",
    "Content-Type" -> "application/json"
}

(* Build a PostgREST equality filter query string: col=eq.val&col2=eq.val2 *)
iFilterString[filters_Association] :=
    StringRiffle[
        KeyValueMap[URLEncode[ToString[#1]] <> "=eq." <> URLEncode[ToString[#2]] &, filters],
        "&"
    ]

iRequest[method_String, path_String] := iRequest[method, path, None]

iRequest[method_String, path_String, body_] := Module[{url, reqOpts, resp},
    url = $SupabaseURL <> "/rest/v1/" <> path;
    reqOpts = <|Method -> method, "Headers" -> iHeaders[]|>;
    If[body =!= None,
        reqOpts = Append[reqOpts, "Body" -> ExportString[body, "JSON"]]
    ];
    resp = URLRead[HTTPRequest[url, reqOpts]];
    If[resp["StatusCode"] >= 400,
        Failure["SupabaseError", <|"StatusCode" -> resp["StatusCode"], "Body" -> resp["Body"]|>],
        Dataset @ ImportString[resp["Body"], "RawJSON"]
    ]
]


(* ----- Public functions ----- *)

SupabaseConnect[url_String, apiKey_String] := (
    $SupabaseURL = StringTrimRight[url, "/"];
    $SupabaseAPIKey = apiKey;
    Dataset[<|"URL" -> $SupabaseURL, "Connected" -> True|>]
)

SupabaseSelect[table_String] := iRequest["GET", table]
SupabaseSelect[table_String, filters_Association] :=
    iRequest["GET", table <> "?" <> iFilterString[filters]]

SupabaseInsert[table_String, data_Association] := iRequest["POST", table, data]
SupabaseInsert[table_String, data : {__Association}] := iRequest["POST", table, data]

SupabaseUpdate[table_String, data_Association, filters_Association] :=
    iRequest["PATCH", table <> "?" <> iFilterString[filters], data]

SupabaseDelete[table_String, filters_Association] :=
    iRequest["DELETE", table <> "?" <> iFilterString[filters]]

SupabaseRPC[fn_String] := iRequest["POST", "rpc/" <> fn]
SupabaseRPC[fn_String, params_Association] := iRequest["POST", "rpc/" <> fn, params]




End[];
EndPackage[];