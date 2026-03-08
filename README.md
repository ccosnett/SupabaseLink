# SupabaseLink
A Mathematica package for connecting to Supabase via the PostgREST REST API.

## Development Setup

To load the paclet directly from a local checkout (without installing it), open a notebook in the root of this repository and run:

```mathematica
(* Run this from a notebook located in the root of the SupabaseLink repository *)
PacletDirectoryLoad[NotebookDirectory[]];
Get["SupabaseLink`"] // Quiet;
?? SupabaseLink`*
```
