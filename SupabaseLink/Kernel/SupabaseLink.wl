(* ::Package:: *)

BeginPackage["SupabaseLink`"]

(* Public symbols *)

$SupabaseURL::usage = "$SupabaseURL is the base URL for the Supabase project (e.g. \"https://<project-ref>.supabase.co\").";

$SupabaseAPIKey::usage = "$SupabaseAPIKey is the Supabase project API key (anon or service_role key).";

SupabaseConnect::usage = "SupabaseConnect[url, apiKey] sets $SupabaseURL and $SupabaseAPIKey for subsequent requests.";

SupabaseSelect::usage = "SupabaseSelect[table] returns all rows from the given table as a Dataset.\nSupabaseSelect[table, filters] applies column filters (given as rules) before returning rows.";

SupabaseInsert::usage = "SupabaseInsert[table, data] inserts a row or list of rows into table. data may be an Association or a list of Associations.";

SupabaseUpdate::usage = "SupabaseUpdate[table, data, filters] updates rows matching filters in table with the key-value pairs in data.";

SupabaseDelete::usage = "SupabaseDelete[table, filters] deletes rows matching filters from table.";

SupabaseRPC::usage = "SupabaseRPC[function] calls a Supabase database function via the PostgREST RPC endpoint.\nSupabaseRPC[function, params] passes the Association params as the JSON body.";

Begin["`Private`"]

(* Utility: build authentication headers *)
supabaseHeaders[] := {
    "apikey" -> $SupabaseAPIKey,
    "Authorization" -> ("Bearer " <> $SupabaseAPIKey),
    "Content-Type" -> "application/json",
    "Accept" -> "application/json"
}

(* Utility: build the PostgREST REST base URL *)
restBase[] := StringTrim[$SupabaseURL, "/"] <> "/rest/v1"

(* Utility: encode a single filter rule as a query parameter *)
filterToParam[col_String -> val_] :=
    col -> ("eq." <> ToString[val, InputForm])

(* Utility: perform a URLRead and parse the JSON response *)
supabaseRequest[req_HTTPRequest] :=
    Module[{resp, body},
        resp = URLRead[req];
        body = resp["Body"];
        If[StringQ[body] && body =!= "",
            Dataset[ImportString[body, "RawJSON"]],
            <|"StatusCode" -> resp["StatusCode"]|>
        ]
    ]

(* --- SupabaseConnect --- *)
SupabaseConnect[url_String, apiKey_String] := (
    $SupabaseURL = url;
    $SupabaseAPIKey = apiKey;
    Success["SupabaseConnect", <|"URL" -> $SupabaseURL|>]
)

(* --- SupabaseSelect --- *)
SupabaseSelect[table_String] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/" <> table,
        <|"Method" -> "GET", "Headers" -> supabaseHeaders[]|>
    ]

SupabaseSelect[table_String, filters:{___Rule}] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/" <> table,
        <|
            "Method" -> "GET",
            "Headers" -> supabaseHeaders[],
            "Query" -> (filterToParam /@ filters)
        |>
    ]

(* --- SupabaseInsert --- *)
SupabaseInsert[table_String, data_Association] :=
    SupabaseInsert[table, {data}]

SupabaseInsert[table_String, data:{___Association}] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/" <> table,
        <|
            "Method" -> "POST",
            "Headers" -> Append[supabaseHeaders[], "Prefer" -> "return=representation"],
            "Body" -> ExportString[data, "RawJSON"]
        |>
    ]

(* --- SupabaseUpdate --- *)
SupabaseUpdate[table_String, data_Association, filters:{___Rule}] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/" <> table,
        <|
            "Method" -> "PATCH",
            "Headers" -> Append[supabaseHeaders[], "Prefer" -> "return=representation"],
            "Query" -> (filterToParam /@ filters),
            "Body" -> ExportString[data, "RawJSON"]
        |>
    ]

(* --- SupabaseDelete --- *)
SupabaseDelete[table_String, filters:{___Rule}] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/" <> table,
        <|
            "Method" -> "DELETE",
            "Headers" -> Append[supabaseHeaders[], "Prefer" -> "return=representation"],
            "Query" -> (filterToParam /@ filters)
        |>
    ]

(* --- SupabaseRPC --- *)
SupabaseRPC[function_String] :=
    SupabaseRPC[function, <||>]

SupabaseRPC[function_String, params_Association] :=
    supabaseRequest @ HTTPRequest[
        restBase[] <> "/rpc/" <> function,
        <|
            "Method" -> "POST",
            "Headers" -> supabaseHeaders[],
            "Body" -> ExportString[params, "RawJSON"]
        |>
    ]

End[]

EndPackage[]
