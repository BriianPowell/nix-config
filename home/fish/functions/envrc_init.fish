function envrc_init -d 'Create an .envrc that loads a dev shell from the nix-config flake'
    argparse h/help 's/shell=' 'f/flake=' -- $argv; or return 1

    if set -q _flag_help
        echo "Usage: envrc_init [-s shell] [-f flake]"
        echo
        echo "  -s, --shell  devShell to load (default: tools)"
        echo "  -f, --flake  flake that provides it (default: \$ENVRC_FLAKE)"
        echo
        echo "Writes .envrc in the current git repo and hides it from git locally."
        echo "It does not run 'direnv allow': read the file, then approve it yourself."
        return 0
    end

    set -q _flag_shell; or set _flag_shell tools
    set -q _flag_flake; or set _flag_flake $ENVRC_FLAKE
    if test -z "$_flag_flake"
        echo "envrc_init: no flake given; pass -f <path> or set ENVRC_FLAKE" >&2
        return 1
    end

    set -l top (command git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$top"
        echo "envrc_init: not inside a git repository" >&2
        return 1
    end

    set -l target $top/.envrc
    if test -e $target
        echo "envrc_init: $target already exists; leaving it alone" >&2
        return 1
    end

    # watch_file reloads the shell when the flake changes.
    printf '%s\n' \
        "watch_file $_flag_flake/flake.nix $_flag_flake/flake.lock" \
        "use flake $_flag_flake#$_flag_shell" >$target

    # .git/info/exclude is local to this clone, so no tracked file changes.
    set -l exclude (command git rev-parse --path-format=absolute --git-path info/exclude)
    command mkdir -p (dirname $exclude)
    grep -qxF .envrc $exclude 2>/dev/null; or echo .envrc >>$exclude

    echo "Wrote $target:"
    command cat $target
    echo
    echo "Review it, then run: direnv allow"
end
