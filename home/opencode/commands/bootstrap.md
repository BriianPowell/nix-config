---
description: Set this repo up for agents (graph, AGENTS.md); asks before writing
agent: build
---

Bootstrap the current repository for coding agents. Work in order and stop to ask
before every step that changes the repo. Never read or print secrets (`.env`,
`*.age`, `*.key`, `secrets/`).

1. Survey (read-only): `git rev-parse --show-toplevel`, the top-level layout, the
   languages in use, and whether `AGENTS.md`, `CLAUDE.md`, `.cursor/rules` or
   `graphify-out/` already exist. Report what you found.
2. Graph: if `graphify-out/graph.json` is missing or older than the latest commit, run
   `graphify update .`. This is code-only and offline; it writes only `graphify-out/`,
   which is globally git-ignored. Do not run any semantic or LLM extraction.
3. Read `graphify-out/GRAPH_REPORT.md`. Use `graphify explain` and `graphify query` for
   anything unclear instead of reading many files.
4. Draft an `AGENTS.md` (or propose edits to the existing one): what the repo is, how
   to build, test and format it, the main modules and how they relate, conventions
   that can be seen in the code, and what must not be touched. Mark anything you
   inferred rather than saw. Show the draft and ask before writing it.
5. Offer, but do not do unprompted: `graphify hook install` (git hooks that rebuild the
   graph on commit/checkout/merge, which edits `.git/hooks`).
6. Finish with a short list of what changed and what is left for the user.

$ARGUMENTS
