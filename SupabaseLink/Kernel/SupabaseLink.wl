(* ::Package:: *)

(* SupabaseLink.wl
   Main entry point for the SupabaseLink Wolfram Language package.
   Loads all sub-contexts and re-exports public symbols.

   Usage:
     << SupabaseLink`
*)

BeginPackage["SupabaseLink`"]

(* ------------------------------------------------------------------ *)
(* Public symbol declarations (usage messages go here)                  *)
(* ------------------------------------------------------------------ *)

(* -- Connection -- *)
$SupabaseURL::usage =
  "$SupabaseURL is the base URL of your Supabase project, e.g. \
\"https://<project-ref>.supabase.co\".";

$SupabaseAPIKey::usage =
  "$SupabaseAPIKey is the anon or service_role key for your project.";

SupabaseConnect::usage =
  "SupabaseConnect[url, apiKey] configures the global connection \
credentials used by all subsequent Supabase operations.";

(* -- Rate limiter (The Seven Samurai gate) -- *)
$SupabaseConcurrency::usage =
  "$SupabaseConcurrency is the maximum number of in-flight requests \
allowed at once (default: 3). The Seven Samurai principle: only let \
the bandits into the village a few at a time.";

WithRateLimit::usage =
  "WithRateLimit[expr] evaluates expr inside the rate-limiting gate, \
blocking until a slot is available.";

(* -- Queries -- *)
SupabaseSelect::usage =
  "SupabaseSelect[table] returns all rows from table as a Dataset.\n\
SupabaseSelect[table, filters] applies equality filters, e.g. \
{\"status\" -> \"active\"}.";

SupabaseRPC::usage =
  "SupabaseRPC[function] calls a Supabase database function.\n\
SupabaseRPC[function, params] passes an Association of parameters.";

(* -- Mutations -- *)
SupabaseInsert::usage =
  "SupabaseInsert[table, data] inserts one Association or a list of \
Associations into table.";

SupabaseUpdate::usage =
  "SupabaseUpdate[table, data, filters] updates rows matching filters \
with the values in data.";

SupabaseDelete::usage =
  "SupabaseDelete[table, filters] deletes rows matching filters.";

(* ------------------------------------------------------------------ *)
(* Load sub-contexts                                                    *)
(* ------------------------------------------------------------------ *)

Get[DirectoryName[$InputFileName] <> "SupabaseLink/Core.wl"]
Get[DirectoryName[$InputFileName] <> "SupabaseLink/RateLimiter.wl"]
Get[DirectoryName[$InputFileName] <> "SupabaseLink/Query.wl"]
Get[DirectoryName[$InputFileName] <> "SupabaseLink/Mutations.wl"]

EndPackage[]
