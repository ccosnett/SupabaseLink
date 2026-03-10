(* run.wl — Load the SupabaseLink paclet and query the Supabase project *)

(* Load the paclet from the local checkout *)
SetDirectory[DirectoryName[$InputFileName]];
PacletDirectoryLoad[FileNameJoin[{Directory[], "SupabaseLink"}]];
Get["SupabaseLink`"] // Quiet;

Print["--- SupabaseLink loaded ---"];
Print["URL:  ", $SupabaseURL];
Print["Key:  ", StringTake[$SupabaseAPIKey, UpTo[12]] <> "..."];

(* Fetch all rows from a table via the paclet *)
(* Since the project may have no tables yet, first list what's available *)
Print["\n--- Querying PostgREST root (available tables/views) ---"];
resp = URLRead[HTTPRequest[
    $SupabaseURL <> "/rest/v1/",
    <|
        "Method"  -> "GET",
        "Headers" -> {
            "apikey"        -> $SupabaseAPIKey,
            "Authorization" -> "Bearer " <> $SupabaseAPIKey
        }
    |>
]];
Print["Status: ", resp["StatusCode"]];
Print["Response: ", resp["Body"]];

(* If you create a table (e.g. "test"), uncomment this to fetch its rows: *)
(* Print[SupabaseSelect["test"]] *)
