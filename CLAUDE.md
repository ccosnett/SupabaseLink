# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SupabaseLink is a Wolfram Language (Mathematica) paclet that connects to a Supabase project via the PostgREST REST API. It exposes CRUD operations and RPC calls as idiomatic Wolfram Language functions, returning `Dataset` objects on success. It is modeled after [OpenAILink](https://github.com/chriswolfram/OpenAILink).

**Scope**: Local development and notebook-based data work. Not intended as a production server library.

---

## Repository Structure

```
SupabaseLink/                    ← repository root
├── CLAUDE.md                    ← this file
├── README.md                    ← quick-start documentation
├── .env.example                 ← template for Supabase credentials
├── .gitignore
├── demo.nb                      ← Mathematica notebook demonstrating usage
├── .github/
│   └── workflows/
│       ├── claude.yml           ← Claude Code automation trigger
│       └── claude-code-review.yml
└── SupabaseLink/                ← the paclet directory (installable unit)
    ├── PacletInfo.wl            ← paclet metadata (name, version, WolframVersion)
    ├── Kernel/
    │   ├── SupabaseLink.wl      ← entry point: BeginPackage, public symbol stubs, loads sub-files
    │   ├── SupabaseConnect.wl   ← all public function implementations
    │   └── LoadDotEnv.wl        ← .env file parser utility
    └── scripts/
        └── installPaclet.wl     ← PacletBuild + PacletInstall script
```

### Key files

| File | Responsibility |
|------|----------------|
| `SupabaseLink/PacletInfo.wl` | Declares paclet name (`SupabaseLink`), version (`0.0.1`), minimum Wolfram version (`13.2+`), and the `Kernel` extension with context `SupabaseLink\`` |
| `SupabaseLink/Kernel/SupabaseLink.wl` | Main entry point. Opens the `SupabaseLink\`` context via `BeginPackage`, declares all public symbols (so they are visible before definitions are loaded), calls `Get` on `LoadDotEnv.wl`, then closes with `EndPackage[]` |
| `SupabaseLink/Kernel/SupabaseConnect.wl` | Implements every public symbol: `$SupabaseURL`, `$SupabaseAPIKey`, `SupabaseConnect`, `SupabaseSelect`, `SupabaseInsert`, `SupabaseUpdate`, `SupabaseDelete`, `SupabaseRPC`. Also contains private HTTP helpers (`iHeaders`, `iFilterString`, `iRequest`). Loaded via `Get` from `SupabaseLink.wl` through `LoadDotEnv.wl` chain |
| `SupabaseLink/Kernel/LoadDotEnv.wl` | Parses a `.env` file (key=value pairs) using `ImportString[..., "Ini"]` and returns an Association. Loaded by both `SupabaseLink.wl` and `SupabaseConnect.wl` |
| `SupabaseLink/scripts/installPaclet.wl` | Builds the paclet archive with `PacletBuild` and installs it locally with `PacletInstall` |

---

## Development Workflow

### Load without installing (preferred for development)

Open a notebook **in the repository root** (or any parent directory) and run:

```mathematica
PacletDirectoryLoad[NotebookDirectory[]];
Get["SupabaseLink`"] // Quiet;
?? SupabaseLink`*
```

This loads the paclet directly from the source tree without building or installing anything.

### Build and install the paclet

Run via `wolframscript`:

```bash
wolframscript -file SupabaseLink/scripts/installPaclet.wl
```

Or from a Wolfram Language session:

```mathematica
Get["SupabaseLink/scripts/installPaclet.wl"]
```

The script calls `PacletBuild[pacletDir]` to produce a `.paclet` archive in a `build/` directory, then calls `PacletInstall` on the result. After installation the paclet is available system-wide via `Needs["SupabaseLink`"]`.

### Configure credentials

Copy `.env.example` to `.env` at the working directory (typically the repository root or notebook directory) and fill in your values:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_API_KEY=your-supabase-api-key-here
```

`LoadDotEnv[]` is called automatically when the paclet loads and populates `$SupabaseURL` / `$SupabaseAPIKey` if the file is found. Credentials can also be set explicitly:

```mathematica
SupabaseConnect["https://your-project.supabase.co", "your-api-key"]
```

### No automated test suite

There is no test runner or linter configured in this repository. Verification is done manually via `demo.nb` or a notebook.

---

## Architecture

### Public API

All public symbols live in the `SupabaseLink\`` context:

| Symbol | Description |
|--------|-------------|
| `$SupabaseURL` | Global mutable state — the trimmed base URL |
| `$SupabaseAPIKey` | Global mutable state — the API key |
| `SupabaseConnect[url, apiKey]` | Stores credentials, returns `Dataset[<\|"URL"->..., "Connected"->True\|>]` |
| `SupabaseSelect[table]` | `GET /rest/v1/<table>` |
| `SupabaseSelect[table, filters]` | `GET /rest/v1/<table>?col=eq.val&...` |
| `SupabaseInsert[table, data]` | `POST /rest/v1/<table>` with JSON body |
| `SupabaseUpdate[table, data, filters]` | `PATCH /rest/v1/<table>?...` with JSON body |
| `SupabaseDelete[table, filters]` | `DELETE /rest/v1/<table>?...` |
| `SupabaseRPC[fn]` | `POST /rest/v1/rpc/<fn>` |
| `SupabaseRPC[fn, params]` | `POST /rest/v1/rpc/<fn>` with JSON body |

### Private helpers (in `SupabaseLink\`SupabaseConnect\`Private\``)

- `iHeaders[]` — builds the four required PostgREST headers: `apikey`, `Authorization: Bearer`, `Accept: application/json`, `Content-Type: application/json`
- `iFilterString[filters_Association]` — encodes equality filters as `col=eq.val&col2=eq.val2` query strings using `URLEncode`
- `iRequest[method, path]` / `iRequest[method, path, body]` — dispatches `URLRead[HTTPRequest[...]]`, serialises body with `ExportString[..., "JSON"]`, parses response with `ImportString[..., "RawJSON"]`, wraps in `Dataset`, and returns `Failure["SupabaseError", ...]` for HTTP status ≥ 400

### Return-type invariant

Every public function returns either:
- `Dataset[...]` on success
- `Failure["SupabaseError", <|"StatusCode"->n, "Body"->s|>]` on HTTP error

### Context / loading order

1. `SupabaseLink.wl` opens `SupabaseLink\`` context, forward-declares all public symbols, `Get`s `LoadDotEnv.wl`, then `EndPackage[]`
2. `SupabaseConnect.wl` opens its own sub-package context (`SupabaseLink\`SupabaseConnect\``), re-`Needs["SupabaseLink\`"]` for the parent context, declares usage messages, loads `LoadDotEnv.wl`, then implements everything inside `Begin["\`Private\`"]`

> Note: `SupabaseConnect.wl` does not appear to be explicitly `Get`-ted by `SupabaseLink.wl` in the current source — only `LoadDotEnv.wl` is. This means `SupabaseConnect.wl` must be loaded separately or the load order relies on `PacletDirectoryLoad` resolving it. This is worth investigating if symbol definitions appear missing after loading.

---

## Dependencies and Tooling

| Dependency | Notes |
|------------|-------|
| Wolfram Language / Mathematica | Version 13.2+ required (specified in `PacletInfo.wl`) |
| Supabase project | Any project with PostgREST enabled (all hosted Supabase projects) |
| No external WL packages | All HTTP via built-in `URLRead`/`HTTPRequest`; JSON via built-in `ImportString`/`ExportString` |
| `.env` file | Optional; credentials can be set programmatically via `SupabaseConnect` |

No Node.js, Python, or other runtimes are required. There is no package manager beyond the built-in `PacletBuild`/`PacletInstall` workflow.

---

## Contribution Guidance

### Commit style

Use Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, etc.

### Wolfram Language conventions to preserve

- **PascalCase** for all public symbols (`SupabaseSelect`, `$SupabaseURL`)
- **Lowercase `i` prefix** for private helpers (`iRequest`, `iHeaders`, `iFilterString`)
- **`BeginPackage` / `EndPackage`** pattern; implementation inside `Begin["\`Private\`"] ... End[]`
- **`Dataset` return type** for all public functions on success
- **`Failure["SupabaseError", ...]`** for HTTP errors — do not throw exceptions
- All filters are `Association`s; all row data is `Association` or `{Association..}`

### Areas requiring extra care

- **`SupabaseLink/PacletInfo.wl`**: Version, `WolframVersion`, and extension context names must stay consistent. Incrementing the version is required for `PacletInstall` to pick up changes when already installed.
- **Context nesting**: `SupabaseLink\``, `SupabaseLink\`SupabaseConnect\``, `SupabaseLink\`LoadDotEnv\`` must not conflict. Adding new sub-packages requires declaring a new context and registering any new kernel files.
- **`$SupabaseURL` and `$SupabaseAPIKey`**: These are global mutable variables. Avoid introducing side effects that reset them unexpectedly.
- **`iFilterString`**: Only supports equality filters (`eq.`). Extending to other PostgREST operators (e.g. `gt.`, `lt.`, `like.`) requires changing the filter encoding logic and the public API signatures.
- **`.env` parsing**: `LoadDotEnv` uses `ImportString[..., "Ini"]` which has known limitations (no multi-line values, no variable expansion, no `export` prefix). Do not change the parser without checking that edge cases in `.env` files are handled.
- **`.gitignore`**: `.env` is gitignored. Never commit real credentials.
