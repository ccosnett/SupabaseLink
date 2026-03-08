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

(* TODO: implement $SupabaseURL *)

(* TODO: implement $SupabaseAPIKey *)

(* TODO: implement SupabaseConnect *)

(* TODO: implement internal HTTP request helper iRequest *)

(* TODO: implement SupabaseSelect *)

(* TODO: implement SupabaseInsert *)

(* TODO: implement SupabaseUpdate *)

(* TODO: implement SupabaseDelete *)

(* TODO: implement SupabaseRPC *)

End[] (* SupabaseLink`Private` *)

EndPackage[] (* SupabaseLink` *)
