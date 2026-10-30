---
description: Review uncommitted changes (read-only)
agent: plan
subtask: true
---

Review the uncommitted changes in this repository.

Diff against HEAD (truncated to 1500 lines):

!`git diff HEAD | head -n 1500`

Untracked files:

!`git ls-files --others --exclude-standard`

Report bugs, risky changes, missing edge cases and anything that contradicts
this repo's AGENTS.md. Do not edit files. List findings by severity, each with a
file and line reference, then give a one-line verdict.
