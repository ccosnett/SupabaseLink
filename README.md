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

## Addendum

### GitHub Workflows

This repository uses a Claude-powered GitHub Actions workflow:

### `claude.yml` — Interactive Assistant (on-demand)

**Trigger:** Mention `@claude` in any issue, issue comment, PR comment, or PR review.

This workflow turns Claude into an interactive assistant you can talk to directly. When you tag `@claude` in a comment or issue body, it spins up a Claude agent that reads your request and responds — answering questions, reviewing code, implementing changes, creating branches, and opening PRs. Claude posts all its responses back as a comment on the same issue or PR.

Example uses:
- `@claude can you explain this function?` — asks a question
- `@claude please fix the bug described above` — triggers a code change + PR

The workflow grants Claude write access to contents, pull requests, and issues so it can act autonomously. It also allows Claude to perform web searches and fetch pages to look up documentation.
