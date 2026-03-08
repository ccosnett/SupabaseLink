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

SupabaseLoadDotEnv::usage =
    "SupabaseLoadDotEnv[] loads credentials from the \".env\" file in the current directory.\n" <>
    "SupabaseLoadDotEnv[file] loads credentials from the specified .env file path.\n" <>
    "Sets $SupabaseURL from SUPABASE_URL and $SupabaseAPIKey from SUPABASE_KEY " <>
    "(or SUPABASE_ANON_KEY / SUPABASE_API_KEY as fallbacks)."

(* ------------------------------------------------------------------ *)
(* Private context                                                     *)
(* ------------------------------------------------------------------ *)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* SupabaseLoadDotEnv                                                  *)
(* ------------------------------------------------------------------ *)

(* Parse a single "KEY=VALUE" line; return Missing if it should be skipped *)
iParseEnvLine[line_String] :=
    Module[{trimmed, eqPos, key, value},
        trimmed = StringTrim[line];
        (* Skip blank lines and comments *)
        If[trimmed === "" || StringStartsQ[trimmed, "#"], Return[Missing["Skipped"]]];
        eqPos = StringPosition[trimmed, "=", 1];
        If[eqPos === {}, Return[Missing["Skipped"]]];
        key   = StringTrim[StringTake[trimmed, First[First[eqPos]] - 1]];
        value = StringTake[trimmed, {Last[First[eqPos]] + 1, -1}];
        (* Strip optional surrounding quotes from value *)
        value = StringReplace[value, StartOfString ~~ ("\"" | "'") ~~ v___ ~~ ("\"" | "'") ~~ EndOfString :> v];
        key -> value
    ]

SupabaseLoadDotEnv::nofile  = "Cannot find or read .env file: `1`."
SupabaseLoadDotEnv::nourl   = "SUPABASE_URL not found in `1`; $SupabaseURL was not set."
SupabaseLoadDotEnv::nokey   = "No API key entry (SUPABASE_KEY / SUPABASE_ANON_KEY / SUPABASE_API_KEY) found in `1`; $SupabaseAPIKey was not set."

SupabaseLoadDotEnv[] := SupabaseLoadDotEnv[".env"]

SupabaseLoadDotEnv[file_String] :=
    Module[{path, lines, pairs, env, url, apiKey, set},
        path = ExpandFileName[file];
        If[!FileExistsQ[path],
            Message[SupabaseLoadDotEnv::nofile, path];
            Return[$Failed]
        ];
        lines = ReadList[path, String];
        pairs = Select[iParseEnvLine /@ lines, !MissingQ[#] &];
        env   = Association[pairs];
        set   = <||>;

        (* --- URL --- *)
        url = Lookup[env, "SUPABASE_URL", Missing["NotFound"]];
        If[MissingQ[url],
            Message[SupabaseLoadDotEnv::nourl, path],
            $SupabaseURL = url;
            AssociateTo[set, "SUPABASE_URL" -> url]
        ];

        (* --- API Key (try three common names in order) --- *)
        apiKey = FirstCase[
            {"SUPABASE_KEY", "SUPABASE_ANON_KEY", "SUPABASE_API_KEY"},
            k_ /; KeyExistsQ[env, k] :> env[k],
            Missing["NotFound"]
        ];
        If[MissingQ[apiKey],
            Message[SupabaseLoadDotEnv::nokey, path],
            $SupabaseAPIKey = apiKey;
            AssociateTo[set, "APIKey" -> apiKey]
        ];

        set
    ]

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
