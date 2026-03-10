(* run.wl — Load the SupabaseLink paclet and query the Supabase project *)

(* Load the paclet from the local checkout *)
SetDirectory[DirectoryName[$InputFileName]];
PacletDirectoryLoad[FileNameJoin[{Directory[], "SupabaseLink"}]];
Get["SupabaseLink`"] // Quiet;

Print["--- SupabaseLink loaded ---"];
Print["URL:  ", $SupabaseURL];
Print["Key:  ", StringTake[$SupabaseAPIKey, UpTo[12]] <> "..."];

(* Query a table using the paclet's SupabaseSelect *)
(* Create a table in Supabase Dashboard first, then put its name here *)
tableName = "position_snapshots";

Print["\n--- SupabaseSelect[\"" <> tableName <> "\"] ---"];
result = SupabaseSelect[tableName];
Print[result];
