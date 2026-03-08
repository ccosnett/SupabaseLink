(* ::Package:: *)

(* SupabaseLink/Mutations.wl
   Write operations: INSERT, UPDATE, DELETE.
   Loaded by Kernel/SupabaseLink.wl.

   All mutation functions route through WithRateLimit[] so the
   Seven Samurai gate applies automatically.
*)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* SupabaseInsert                                                       *)
(* ------------------------------------------------------------------ *)

(* Insert a single row (Association) into table.
   Returns the inserted row(s) as a Dataset.
   TODO: add "upsert" support via Prefer: resolution=merge-duplicates *)
SupabaseInsert[table_String, row_Association] :=
  SupabaseInsert[table, {row}]

(* Insert multiple rows (list of Associations) into table.
   For large lists, consider using iBatch[] from RateLimiter.wl
   instead of inserting the whole list at once.
   TODO: add batch size option                                         *)
SupabaseInsert[table_String, rows_List] :=
  Module[{path, result},
    path   = "/rest/v1/" <> table;
    result = WithRateLimit[iRequest["POST", path, rows]];
    Dataset[result]
  ]

(* ------------------------------------------------------------------ *)
(* SupabaseUpdate                                                       *)
(* ------------------------------------------------------------------ *)

(* Update rows in table that match filters, applying the values in data.
   - data    : Association of column -> newValue pairs
   - filters : Association or List of equality conditions

   WARNING: omitting filters will update every row in the table.
            PostgREST requires at least one filter for safety by default;
            check your PostgREST config if you need bulk updates.
   TODO: enforce non-empty filters unless an option explicitly allows it *)
SupabaseUpdate[table_String, data_Association, filters_] :=
  Module[{path, result},
    path   = "/rest/v1/" <> table <> iFiltersToQueryString[filters];
    result = WithRateLimit[iRequest["PATCH", path, data]];
    Dataset[result]
  ]

(* ------------------------------------------------------------------ *)
(* SupabaseDelete                                                       *)
(* ------------------------------------------------------------------ *)

(* Delete rows matching filters from table.
   Returns the deleted rows as a Dataset (requires Prefer: return=representation).

   WARNING: omitting filters deletes all rows.
   TODO: same safety guard as SupabaseUpdate                          *)
SupabaseDelete[table_String, filters_] :=
  Module[{path, result},
    path   = "/rest/v1/" <> table <> iFiltersToQueryString[filters];
    result = WithRateLimit[iRequest["DELETE", path, None]];
    Dataset[result]
  ]

End[] (* SupabaseLink`Private` *)
