---
name: repo-bootstrap
description: Understand an unfamiliar repository quickly using the graphify code graph, and write or improve its AGENTS.md. Use when starting work in a repo with no AGENTS.md, when asked to explain a codebase's structure, or when asked to bootstrap a repo for agents.
---

## Orient

- Check `AGENTS.md`, `CLAUDE.md`, `README*`, `.cursor/rules` first; they beat inference.
- Prefer the graph to broad greps: `graphify-out/GRAPH_REPORT.md` lists the central
  nodes and communities; `graphify explain "<name>"` shows a node and its neighbours;
  `graphify path "A" "B"` shows how two things connect; `graphify query "<question>"`
  traverses from matching nodes.
- Build or refresh with `graphify update .` (code only, offline). It does not index
  prose or PDFs, so read those directly.
- Treat the graph as a map, not truth: edges are extracted statically, so dynamic
  dispatch, reflection and generated code are missing. Confirm in the source before
  acting on a relationship.

## Writing AGENTS.md

Keep it short; every line is paid for in context on every request.

- Purpose of the repo in two sentences.
- Exact commands to build, test, lint and format, taken from the Makefile, CI config
  or package scripts, not guessed.
- Layout: only directories whose purpose is not obvious from the name.
- Conventions you can point to in the code, and things not to touch (generated files,
  vendored code, secrets).
- Mark unverified statements as such.

## Guardrails

- Do not run `graphify hook install`, `graphify install` or `graphify opencode install`
  unless the user asks: they edit the repo or its git hooks.
- Do not commit `graphify-out/`; it is globally ignored.
- Do not add MCP servers or install tools to a repo without asking.
