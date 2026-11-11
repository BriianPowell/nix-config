function repo_init -d 'Set up the current git repo for direnv (dev shell) and AI agents (AGENTS.md)'
    argparse h/help 's/shell=' 'f/flake=' 'no-envrc' 'l/local' -- $argv; or return 1

    if set -q _flag_help
        echo "Usage: repo_init [-s shell] [-f flake] [--no-envrc] [-l|--local]"
        echo
        echo "  1. envrc_init: .envrc that loads the dev shell, hidden from git locally"
        echo "  2. AGENTS.md:  short skeleton, read by OpenCode, Cursor and Codex-style tools"
        echo "  3. CLAUDE.md:  one line, '@AGENTS.md', so Claude Code reads the same file"
        echo
        echo "  -l, --local  also hide AGENTS.md and CLAUDE.md from git in this clone only"
        echo "               (.git/info/exclude), for repos you do not own"
        echo
        echo "Existing files are never overwritten. Nothing is committed and 'direnv allow'"
        echo "is not run. Afterwards ask an agent to run /bootstrap to fill AGENTS.md in."
        return 0
    end

    set -l top (command git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$top"
        echo "repo_init: not inside a git repository" >&2
        return 1
    end

    if not set -q _flag_no_envrc
        set -l created 0
        if test -e $top/.envrc
            echo "repo_init: .envrc already exists; leaving it alone"
        else
            set -l args
            set -q _flag_shell; and set args $args -s $_flag_shell
            set -q _flag_flake; and set args $args -f $_flag_flake
            envrc_init $args; or return 1
            set created 1
        end

        # Node versions come from nvm.fish, which does not switch on `cd`. A repo that pins
        # one gets `use_nvmrc` (home/direnv/use_nvmrc.sh) so direnv puts it on PATH. Only
        # added to an .envrc created in this run: an existing one is the user's to edit.
        set -l direnv_lib (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo ~/.config)/direnv/lib/use_nvmrc.sh
        if test -e $top/.nvmrc -o -e $top/.node-version; and test -e $direnv_lib
            if grep -q use_nvmrc $top/.envrc 2>/dev/null
                :
            else if test $created -eq 1
                echo use_nvmrc >>$top/.envrc
                echo "Added use_nvmrc to .envrc (this repo pins a Node version); if it is not installed: nvm install"
            else
                echo "repo_init: this repo pins a Node version; add 'use_nvmrc' to .envrc to load it"
            end
        end
    end

    set -l name (basename $top)

    if test -e $top/AGENTS.md
        echo "repo_init: AGENTS.md already exists; leaving it alone"
    else
        # Placeholders are deliberate: a wrong guess costs more than a gap, and
        # /bootstrap (OpenCode, Claude Code, Cursor) fills these from the code.
        printf '%s\n' \
            "# $name" \
            "" \
            "<!-- TODO: two sentences on what this repo is. -->" \
            "" \
            "## Verify before you finish" \
            "" \
            "Run these and fix failures before reporting a task done. Report which ones you ran." \
            "" \
            "<!-- TODO: exact lint, test and build commands, taken from CI or package scripts." \
            "     Write 'none found' rather than guessing. -->" \
            "" \
            "## Commands" \
            "" \
            "<!-- TODO: other commands worth knowing (format, run, deploy). -->" \
            "" \
            "## Layout" \
            "" \
            "<!-- TODO: only directories whose purpose is not obvious from the name. -->" \
            "" \
            "## Conventions" \
            "" \
            "- Never read, print or commit secrets (`.env`, keys, tokens)." \
            "- When a change alters a command, the layout or a convention above, update this file in the same change." \
            "- Do not commit or push unless asked." >$top/AGENTS.md
        echo "Wrote $top/AGENTS.md"
    end

    # Claude Code reads CLAUDE.md, not AGENTS.md; the import keeps one source of truth.
    if test -e $top/CLAUDE.md
        echo "repo_init: CLAUDE.md already exists; leaving it alone"
    else
        echo "@AGENTS.md" >$top/CLAUDE.md
        echo "Wrote $top/CLAUDE.md"
    end

    # For repos that are not yours (work repos, upstream projects): keep the agent
    # files out of `git status` in this clone only. A file the repo already tracks is
    # left alone, since excluding a tracked file does nothing.
    if set -q _flag_local
        set -l exclude (command git rev-parse --path-format=absolute --git-path info/exclude)
        command mkdir -p (dirname $exclude)
        for f in AGENTS.md CLAUDE.md
            test -e $top/$f; or continue
            if command git -C $top ls-files --error-unmatch $f >/dev/null 2>&1
                echo "repo_init: $f is tracked by this repo; not excluding it"
            else
                grep -qxF /$f $exclude 2>/dev/null; or echo /$f >>$exclude
                echo "Excluded $f locally (.git/info/exclude)"
            end
        end
    end
end
