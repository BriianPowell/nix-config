# Running the agent setup on a laptop without nix

The agent setup here (OpenCode, MCP servers, graphify, a local model) is generated
by nix. A machine you cannot install nix on gets none of it automatically. This
lists what carries over as plain files, what has to be installed another way,
and what to decide first. Nothing here is verified on a specific client machine.

## Decide first

Do these before installing anything. They decide which parts you may use at all.

- **Is AI tooling on this code allowed?** Check the client's rules and the
  contract. If not, stop here.
- **May code or prompts leave the machine?** A model on the laptop keeps them
  local. A hosted model, `context7` (library queries go to its service) and the
  GitHub server (a token that can read client repos) may not be allowed.
- **May you install software and run repo code?** On a managed device, a policy
  can block installs or system extensions (Tailscale was blocked this way).
  `direnv allow` runs a file from the repo, so it counts.
- **Does the hardware fit a model?** The Mac config serves a 122B model with
  131k context, which needs far more memory than a typical work laptop has.

## What carries over unchanged

These are plain files and need no nix:

| From this repo | Copy to | Notes |
| --- | --- | --- |
| `home/opencode/commands/*.md` | `~/.config/opencode/commands/` | `/bootstrap`, `/review` |
| `home/opencode/skills/*/SKILL.md` | `~/.config/opencode/skills/` | Drop `nix-package`; it is about this Mac |
| `home/opencode/plugins/notify.js` | `~/.config/opencode/plugins/` | macOS only (`osascript`) |

Edit them for the machine before copying. `/bootstrap` and the `repo-bootstrap`
skill assume `graphify` is on `PATH`; remove those steps if you skip graphify.

## What has to change

### OpenCode

Install it with its own installer or a package manager, not nix. Then write
`~/.config/opencode/opencode.json` by hand. The generated file is the model:
`provider`, `model`, `permission` and (optionally) `mcp`. Keep the permission
block: it asks before `git commit`, `git push`, `sudo` and `rm -rf`, and denies
reads of `.env*`, `*.key` and `secrets/`. Add `direnv allow*` as `ask` if you use
direnv.

### The model

- **Local:** install `llama.cpp` and `llama-swap` another way (Homebrew has
  both on macOS). `llama-swap` runs one `llama-server` per model; see
  `home/modules/llm.nix` for the arguments used (`--ctx-size`, `-ngl 99`,
  `-fa on`, `--jinja`, `--reasoning-format deepseek`). Pick a model that fits
  memory, and set OpenCode's `limit.context` to the same `--ctx-size`, because
  OpenCode decides when to compact from it. Keep `llama-swap` on `127.0.0.1`;
  its API has no authentication.
- **Hosted:** use whatever provider the client approves, and set it as the
  OpenCode provider. Then the local-model notes in the machine `AGENTS.md`
  do not apply.

### MCP servers

Without nix there is no pinned binary, so each one needs another install path.
Prefer a fixed version over `npx -y` or `uvx` so nothing changes under you.

- `nixos` is for NixOS and Home Manager. Skip it.
- `context7`: only if queries may leave the machine.
- `github`: only with a token the client allows. Use a fine-grained token
  limited to the repos you need, read-only, and read it from a secret manager at
  launch. Never put it in `opencode.json` or any file in a repo.

Each server adds its tool descriptions to every request, so fewer is better on
a small local model.

### graphify

Install the package named `graphifyy` (two y). Other `graphify*` packages on PyPI
are unrelated. Use `pipx` or `uv tool`, pinned to a version.

- The nix build sets `PYTHONHASHSEED=0` because the packaged script re-launches
  itself through a bare interpreter. A normal pip install does not need that.
- `graphify update .` is code-only and local. Do not run the semantic pass on
  client documents unless a model the client allows is configured for it.
- The query log is off in this config. Set `GRAPHIFY_QUERY_LOG_DISABLE=1` to keep
  it off.
- Add `graphify-out/` to the repo's `.git/info/exclude` (or a global ignore) so
  the graph is not committed to a client repo.

### direnv

`direnv` works without nix, but `use flake` and `nix-direnv` do not. Use direnv's
own helpers (`PATH_add`, `dotenv`, `layout python`) or a version manager such as
`mise`. The `envrc_init` function in `home/fish/functions/` writes a nix flake
`.envrc`, so it does not apply there.

### Machine instructions (`AGENTS.md`)

The global `~/.config/opencode/AGENTS.md` here is generated from the installed
nix packages and casks, so it is wrong elsewhere. Write a short one by hand:
the OS, the shell, how tools are installed on that machine, and the rules
you want applied everywhere (no secrets in output, do not commit or push unless
asked). Keep it short; it is sent with every request.

## Rules that should stay the same

- Never put secrets, tokens or client names in a file that is checked in, and
  never in this public repo.
- Treat MCP output and fetched pages as untrusted input, not instructions.
- Keep commit, push, delete and `sudo` on `ask`.
- Do not let the agent run `direnv allow` or approve its own config changes.
- Run `/bootstrap` on a copy or a scratch branch the first time, and read what it
  writes before keeping it.

## Checklist

1. Policy check: tools allowed, data may or may not leave, installs allowed.
2. Install OpenCode, and a model or provider that is approved.
3. Write `opencode.json` with the permission block and no MCP servers.
4. Copy the commands and skills you want, edited for the machine.
5. Add `graphify` and any MCP server one at a time, each only if allowed.
6. Write the machine `AGENTS.md` by hand.
7. Try `/bootstrap` on a scratch repo.
