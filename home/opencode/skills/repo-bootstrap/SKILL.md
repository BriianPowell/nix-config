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
- A "Verify before you finish" section: the exact lint, test and build commands the
  agent must run and report before calling a task done. Take them from CI config, the
  Makefile or package scripts; if there are none, write "none found", never a guess.
- Other commands worth knowing (format, run, deploy), same sourcing rule.
- Layout: only directories whose purpose is not obvious from the name.
- Conventions you can point to in the code, and things not to touch (generated files,
  vendored code, secrets).
- Mark unverified statements as such.

### Size and structure

- Aim for about 100 lines at most. Past that, move detail into `docs/` and link to it
  with a plain path, not an `@path` import: imports are loaded into every session, a plain
  link is read only when needed.
- In a monorepo, put package-specific rules in an `AGENTS.md` inside that package and keep
  the root file to what applies everywhere. Nested-file support differs by tool (Claude
  Code reads a subdirectory `CLAUDE.md` on demand; VS Code Copilot needs
  `chat.useNestedAgentsMdFiles`), so check before relying on it.
- Leave out what the agent can read from the code: file listings, dependency lists,
  generic style advice, and anything the linter already enforces.
- Prefer a command to a number or version in prose. "28 entries" goes stale; the `grep`
  that counts them does not.
- Every statement should be checkable. If you cannot confirm it, mark it unverified or
  drop it.

### Keeping it current

- A stale AGENTS.md is worse than a short one: agents trust it. Update it in the same
  change that alters a documented command, directory or convention, and say so in the
  summary. A pull request that renames a script but leaves the file pointing at the old
  name is incomplete.
- Before finishing work in a repo that has one, re-check the lines the change touches
  (a renamed path, a changed command, a new tool the "Verify" section should run).
- When you notice a line you can prove is wrong, fix it or flag it; do not work around it.
- There is no automated check for this on purpose: a script cannot tell stale from
  correct, and a noisy check gets ignored.

## Guardrails

- Do not run `graphify hook install`, `graphify install` or `graphify opencode install`
  unless the user asks: they edit the repo or its git hooks.
- Do not commit `graphify-out/`; it is globally ignored.
- Do not add MCP servers or install tools to a repo without asking.
