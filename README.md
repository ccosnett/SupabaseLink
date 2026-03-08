# SupabaseLink
A Mathematica package for connecting to Supabase via the PostgREST REST API.

## Configuration

### Setting Up Secrets

SupabaseLink requires two variables to connect to your Supabase project:

- **`$SupabaseURL`** — The base URL of your Supabase project (e.g. `https://your-project-id.supabase.co`)
- **`$SupabaseAPIKey`** — Your project API key (`anon` key for public access, `service_role` key for admin access)

You can find both values in your Supabase dashboard under **Project Settings → API**.

Set them in your Mathematica session before making any calls:

```mathematica
$SupabaseURL = "https://your-project-id.supabase.co";
$SupabaseAPIKey = "your-supabase-api-key-here";
```

A `.env.example` file is included in this repository as a reference for the required environment variables.

## Development Setup

To load the paclet directly from a local checkout (without installing it), open a notebook in the root of this repository and run:

```mathematica
(* Run this from a notebook located in the root of the SupabaseLink repository *)
PacletDirectoryLoad[NotebookDirectory[]];
Get["SupabaseLink`"] // Quiet;
```
