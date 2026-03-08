(* ::Package:: *)

(* SupabaseLink/Core.wl
   Connection configuration and low-level HTTP helpers.
   This file is loaded by Kernel/SupabaseLink.wl — do not load it directly.
*)

Begin["SupabaseLink`Private`"]

(* ------------------------------------------------------------------ *)
(* Global connection state                                              *)
(* ------------------------------------------------------------------ *)

(* Default values — override via SupabaseConnect[] or direct assignment *)
$SupabaseURL    = None
$SupabaseAPIKey = None

(* ------------------------------------------------------------------ *)
(* SupabaseConnect                                                      *)
(* ------------------------------------------------------------------ *)

(* TODO: implement credential validation / ping test *)
SupabaseConnect[url_String, apiKey_String] :=
  Module[{},
    $SupabaseURL    = url;
    $SupabaseAPIKey = apiKey;
    (* Return a summary association so callers can confirm settings *)
    <|"URL" -> $SupabaseURL, "KeyPrefix" -> StringTake[apiKey, UpTo[8]] <> "..."|>
  ]

(* ------------------------------------------------------------------ *)
(* Internal HTTP helper                                                 *)
(* ------------------------------------------------------------------ *)

(* iRequest[method, path, body]
   Low-level wrapper around URLRead.
   - method : "GET" | "POST" | "PATCH" | "DELETE"
   - path   : REST path relative to $SupabaseURL, e.g. "/rest/v1/my_table"
   - body   : Association or None

   Returns the parsed JSON response as a Wolfram expression.
   Signals a Failure on HTTP errors.
*)
iRequest[method_String, path_String, body_] :=
  Module[{url, headers, req, resp, parsed},

    (* TODO: validate $SupabaseURL / $SupabaseAPIKey are set *)

    url = $SupabaseURL <> path;

    headers = {
      "apikey"        -> $SupabaseAPIKey,
      "Authorization" -> "Bearer " <> $SupabaseAPIKey,
      "Content-Type"  -> "application/json",
      (* Ask PostgREST for full row representation after mutations *)
      "Prefer"        -> "return=representation"
    };

    req = HTTPRequest[url,
      <|
        "Method"  -> method,
        "Headers" -> headers,
        If[body =!= None,
          "Body" -> ExportString[body, "JSON"],
          Nothing
        ]
      |>
    ];

    (* TODO: wrap in WithRateLimit[] once RateLimiter.wl is wired up *)
    resp = URLRead[req];

    (* TODO: handle non-2xx status codes with Failure[] *)

    parsed = ImportString[resp["Body"], "JSON"];
    parsed
  ]

End[] (* SupabaseLink`Private` *)
