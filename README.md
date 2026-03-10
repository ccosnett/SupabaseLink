# SupabaseLink
A Mathematica package for connecting to Supabase via the PostgREST REST API.

## GitHub Workflows

This repository uses two Claude-powered GitHub Actions workflows:

### `claude.yml` — Interactive Assistant (on-demand)

**Trigger:** Mention `@claude` in any issue, issue comment, PR comment, or PR review.

This workflow turns Claude into an interactive assistant you can talk to directly. When you tag `@claude` in a comment or issue body, it spins up a Claude agent that reads your request and responds — answering questions, reviewing code, implementing changes, creating branches, and opening PRs. Claude posts all its responses back as a comment on the same issue or PR.

Example uses:
- `@claude can you explain this function?` — asks a question
- `@claude please fix the bug described above` — triggers a code change + PR

The workflow grants Claude write access to contents, pull requests, and issues so it can act autonomously. It also allows Claude to perform web searches and fetch pages to look up documentation.

### `claude-code-review.yml` — Automated Code Review (automatic on every PR)

**Trigger:** Automatically runs on every pull request when it is opened, updated, marked ready for review, or reopened. No `@claude` mention required.

This workflow runs a structured code review on every PR without any manual prompt. It uses a dedicated `code-review` plugin (loaded from the Anthropic Claude Code plugins repository) and passes the PR number to Claude so it can fetch and review the diff. Claude then posts a review comment summarising issues, suggestions, and observations about the changed code.

Key detail: `allowed_bots: 'claude[bot]'` is set, which means Claude is permitted to trigger a review even on PRs that Claude itself opened. This is flagged in the workflow with a warning because it could theoretically cause an infinite review loop, but in practice each PR only gets one automated review pass.

### Summary

| | `claude.yml` | `claude-code-review.yml` |
|---|---|---|
| **Trigger** | `@claude` mention | Every PR automatically |
| **Purpose** | Interactive assistant | Automated code review |
| **Requires human prompt?** | Yes | No |
| **Reviews PRs?** | On request | Always |
| **Can make code changes?** | Yes | No |

## Development Setup

To load the paclet directly from a local checkout (without installing it), open a notebook in the root of this repository and run:

```mathematica
(* Run this from a notebook located in the root of the SupabaseLink repository *)
PacletDirectoryLoad[NotebookDirectory[]];
Get["SupabaseLink`"] // Quiet;
?? SupabaseLink`*
```
