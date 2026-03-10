# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Mathematica package connecting to Supabase via PostgREST REST API. Modeled after https://github.com/chriswolfram/OpenAILink.

## Structure

The repository root contains a `SupabaseLink/` subdirectory which is the paclet directory itself:

```
/ (repo root)
├── CLAUDE.md
├── README.md
├── demo.nb
└── SupabaseLink/               ← paclet root (passed to PacletBuild / PacletDirectoryLoad)
    ├── PacletInfo.wl           ← paclet metadata (Name, Version, WolframVersion, Extensions)
    ├── Kernel/                 ← Kernel extension root (Root -> "Kernel" in PacletInfo.wl)
    │   ├── SupabaseLink.wl     ← package entry point; declares public symbols, loads sub-files
    │   ├── SupabaseConnect.wl  ← SupabaseConnect[] and connection helpers
    │   └── LoadDotEnv.wl       ← .env file parser for $SupabaseURL / $SupabaseAPIKey
    └── scripts/
        └── installPaclet.wl    ← build + install script (PacletBuild then PacletInstall)
```

- Wolfram Language (`.wl`), PascalCase symbols, `Dataset` return types
- `BeginPackage` / `EndPackage` pattern with `Private` context
- Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.

## Paclet System

A paclet is a self-contained unit of Wolfram functionality. Its essential element is `PacletInfo.wl` — a metadata file that describes the paclet, its requirements, and the ways it extends the Wolfram environment.

### PacletInfo.wl format

`PacletInfo.wl` uses a `PacletObject[<| ... |>]` expression (an Association, not a list):

```wolfram
PacletObject[
    <|
        "Name"           -> "SupabaseLink",
        "Version"        -> "0.0.1",
        "WolframVersion" -> "13.2+",
        "Extensions"     ->
            {
                {
                    "Kernel",
                    "Root"    -> "Kernel",
                    "Context" -> "SupabaseLink`"
                }
            }
    |>
]
```

Key fields:
- **Name** — paclet identifier; use underscores not hyphens for word separation
- **Version** — up to five numeric blocks (e.g. `"1.0.0"`), compared numerically; always increment before release
- **WolframVersion** — compatibility range: `"13.2+"` means 13.2 and later; also supports `"13.*"`, `"12.3,13.0"`
- **Extensions** — list of extension specifications (see below)
- **Loading** — `"Manual"` (default), `"Startup"`, or `"Automatic"`; this paclet uses the default Manual

### Kernel extension

The `Kernel` extension tells Wolfram Language where to find `.wl` / `.m` packages:

```wolfram
{"Kernel", "Root" -> "Kernel", "Context" -> "SupabaseLink`"}
```

- `"Root" -> "Kernel"` means package files live in `SupabaseLink/Kernel/`
- `"Context" -> "SupabaseLink`"` means `Needs["SupabaseLink`"]` loads `Kernel/SupabaseLink.wl`
- Subcontexts map to sub-files: `"SupabaseLink`Sub`"` resolves to `Kernel/Sub.wl`

Path resolution order: `paclet location / paclet root / extension root / resource path`

## Development Workflow

### Load for development (no install required)

Use `PacletDirectoryLoad` to add the paclet directory to the search path for the current session. This is preferred during active development because no archive or install step is needed:

```wolfram
PacletDirectoryLoad["/path/to/repo/SupabaseLink"];  (* points at the paclet subdirectory *)
Needs["SupabaseLink`"]
```

`PacletDirectoryLoad` wins version-number ties — a directory-loaded paclet overrides an installed paclet with the same version number, so you can test without bumping the version.

After editing `PacletInfo.wl`, call `PacletDataRebuild[]` to rescan without restarting the kernel.

### Build and install

`scripts/installPaclet.wl` builds a `.paclet` archive and installs it:

```wolfram
(* Run from within Wolfram Language *)
Get["/path/to/repo/SupabaseLink/scripts/installPaclet.wl"]
```

Internally it does:
```wolfram
$pacletDir  = FileNameJoin[{DirectoryName[$InputFileName], ".."}];  (* SupabaseLink/ *)
buildResult = PacletBuild[$pacletDir];                              (* creates .paclet archive *)
PacletInstall[buildResult["Location"]]                              (* installs it locally *)
```

`PacletBuild` produces a compressed `.paclet` archive (a renamed ZIP). The archive is placed in a `build/` directory.

### Key paclet commands

| Command | Purpose |
|---|---|
| `PacletDirectoryLoad[dir]` | Add dev directory to session search path |
| `PacletDirectoryUnload[dir]` | Remove from search path |
| `PacletDataRebuild[]` | Rescan PacletInfo.wl after manual edits |
| `PacletBuild[dir]` | Compile paclet directory into `.paclet` archive |
| `PacletInstall[path]` | Install from `.paclet` file or URL |
| `PacletFind["SupabaseLink"]` | Locate installed paclet |
| `PacletObject["SupabaseLink"]` | Get active paclet representation |
| `CreatePacletArchive[dir]` | Alternative archive creation |

### Configuration

Copy `.env.example` to `.env` (at the repo root or notebook directory) with:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_API_KEY=your-anon-key
```

`LoadDotEnv.wl` parses this file and sets `$SupabaseURL` and `$SupabaseAPIKey`.

## Architecture

### Public API

| Symbol | Description |
|---|---|
| `$SupabaseURL` | Project URL, loaded from environment |
| `$SupabaseAPIKey` | API key, loaded from environment |
| `SupabaseConnect[]` | Validates credentials and returns a connection object |
| `SupabaseSelect[conn, table, opts]` | SELECT rows, returns `Dataset` |
| `SupabaseInsert[conn, table, data]` | INSERT rows |
| `SupabaseUpdate[conn, table, filter, data]` | UPDATE rows |
| `SupabaseDelete[conn, table, filter]` | DELETE rows |
| `SupabaseRPC[conn, fn, args]` | Call a Postgres function via PostgREST RPC |

All public functions return `Dataset` on success or `Failure` on error.

### Loading order

1. `SupabaseLink.wl` — `BeginPackage["SupabaseLink`"]`, declares all public symbols, then `Get`s `LoadDotEnv.wl`
2. `LoadDotEnv.wl` — parses `.env`, sets globals
3. `SupabaseConnect.wl` — loaded on demand; defines connection helpers and the private `iHeaders`, `iFilterString`, `iRequest` helpers

### Private conventions

- Private symbols use an `i` prefix (`iHeaders`, `iFilterString`, `iRequest`)
- All private code lives in `SupabaseLink`Private`` context (via `Begin["Private`"]` / `End[]`)

## Dependencies and Tooling

- **Wolfram Language 13.2+** — `"WolframVersion" -> "13.2+"` in `PacletInfo.wl`
- No external packages; uses only built-in `URLRead`, `HTTPRequest`, `ImportString` for HTTP/JSON
- No build tools beyond the built-in `PacletBuild` / `PacletInstall`

## Contribution Guidance

### Paclet versioning

Always increment `"Version"` in `SupabaseLink/PacletInfo.wl` before publishing a release. Version strings are compared numerically block by block. The current version is `"0.0.1"`.

### Editing PacletInfo.wl

After any change to `PacletInfo.wl`, call `PacletDataRebuild[]` so Wolfram Language picks up the new metadata without restarting the kernel.

### WL code conventions

- PascalCase for all public symbols
- `i` prefix for private helpers
- `BeginPackage` / `EndPackage` wraps each `.wl` file; private code inside `Begin["Private`"]` / `End[]`
- Return `Dataset` or `Failure` — never raw associations or unevaluated expressions from public functions

### Areas requiring extra care

- **`PacletInfo.wl`** — the `PacletObject[<| ... |>]` wrapper and Association syntax are mandatory; malformed files silently prevent the paclet from loading
- **Kernel extension** — the `"Root" -> "Kernel"` path must match the actual directory name exactly (case-sensitive on Linux/macOS)
- **`$SupabaseURL` / `$SupabaseAPIKey`** — these are global mutable variables set by `LoadDotEnv`; do not shadow or `Clear` them inside functions
- **Filter encoding** — PostgREST filter strings use specific operator syntax (`eq.`, `gt.`, `like.`, etc.); `iFilterString` must produce valid query parameters
- **`.env` parsing** — `LoadDotEnv.wl` reads from the notebook directory; tests run outside a notebook need the path set explicitly
