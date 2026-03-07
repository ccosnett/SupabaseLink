# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Mathematica package connecting to Supabase via PostgREST REST API. Modeled after https://github.com/chriswolfram/OpenAILink.

## Structure

```
SupabaseLink/
├── PacletInfo.wl
├── Kernel/
│   └── SupabaseLink.wl
├── scripts/
│   └── installPaclet.wl
└── build/
```

- Wolfram Language (`.wl`), PascalCase symbols, `Dataset` return types
- `BeginPackage` / `EndPackage` pattern with `Private` context
- `PacletBuild` + `PacletInstall` workflow via `scripts/installPaclet.wl`
