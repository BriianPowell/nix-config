function hass_deploy -d 'Pull hass-config on sheol, check it with Home Assistant, then restart'
    # The config lives in a git clone on sheol (the volume behind the homeassistant PVC). This does
    # what `git pull` there did by hand, plus a Home Assistant config check, and puts the clone back
    # if the check fails so a bad push never sits on the volume waiting for the next restart.
    argparse h/help c/check y/yes n/no-restart -- $argv; or return 1

    set -l host sheol # ssh alias, user boog
    set -l dir /mnt/moriyya/homeassistant/config
    set -l ns homeassistant

    if set -q _flag_help
        echo "Usage: hass_deploy [-c] [-y] [-n]"
        echo
        echo "Fetches hass-config on $host, shows what would change, pulls it (fast-forward only),"
        echo "runs Home Assistant's own config check against the result and, if that passes,"
        echo "restarts Home Assistant. A failed check puts the clone back where it was."
        echo
        echo "  -c, --check       only fetch, show the pending changes and check the current config;"
        echo "                    pull and restart nothing"
        echo "  -y, --yes         restart without asking"
        echo "  -n, --no-restart  pull and check, never restart (for changes you reload from the UI:"
        echo "                    automations, scripts, scenes, templates, dashboards, themes)"
        echo
        echo "Refuses to run if the clone on $host has uncommitted tracked changes. A restart is"
        echo "needed for integration, auth_oidc, mqtt and similar changes. Needs ssh access to"
        echo "$host and kubectl access to the cluster."
        return 0
    end

    set -l check_cmd kubectl -n $ns exec deploy/homeassistant -- \
        python3 -m homeassistant --script check_config -c /config

    echo "==> fetching $host:$dir"
    command ssh $host "git -C $dir fetch --quiet origin"; or begin
        echo "hass_deploy: could not fetch on $host" >&2
        return 1
    end

    set -l dirty (command ssh $host "git -C $dir status --porcelain --untracked-files=no")
    if test (count $dirty) -gt 0
        echo "hass_deploy: uncommitted changes in $dir on $host; resolve them there first:" >&2
        printf '  %s\n' $dirty >&2
        return 1
    end

    set -l old (command ssh $host "git -C $dir rev-parse HEAD")
    set -l upstream (command ssh $host "git -C $dir rev-parse '@{u}'")
    set -l branch (command ssh $host "git -C $dir branch --show-current")
    test "$branch" != main; and echo "Warning: the clone is on branch '$branch', not main"

    set -l changed
    if test "$old" = "$upstream"
        echo "Already up to date ($(string sub -l 8 $old))."
    else
        echo "==> pending changes ($(string sub -l 8 $old)..$(string sub -l 8 $upstream)):"
        command ssh $host "git -C $dir log --oneline HEAD..'@{u}'; echo; git -C $dir diff --stat HEAD..'@{u}'"
        set changed (command ssh $host "git -C $dir diff --name-only HEAD..'@{u}'")
    end

    if set -q _flag_check
        echo "==> checking the config currently on the volume (nothing is pulled)"
        command $check_cmd
        return $status
    end

    if test "$old" != "$upstream"
        echo "==> pulling"
        command ssh $host "git -C $dir pull --ff-only --quiet"; or begin
            echo "hass_deploy: pull failed (not a fast-forward?); nothing changed" >&2
            return 1
        end
    end

    echo "==> Home Assistant config check"
    command $check_cmd
    if test $status -ne 0
        echo "hass_deploy: the config check FAILED." >&2
        if test "$old" != "$upstream"
            echo "Putting the clone back at $(string sub -l 8 $old)." >&2
            command ssh $host "git -C $dir reset --hard $old" >/dev/null
        end
        echo "Home Assistant was not restarted." >&2
        return 1
    end

    if set -q _flag_no_restart
        echo "Config OK. Not restarting (-n)."
        return 0
    end

    # Only UI-reloadable areas changed: say so, and make "no" the easy answer.
    set -l reloadable_only 0
    if test (count $changed) -gt 0
        set reloadable_only 1
        for f in $changed
            if not string match -qr '^(automations|lovelace|themes|www|blueprints)/|^includes/(scripts|scenes|templates)' -- $f
                set reloadable_only 0
                break
            end
        end
    end
    test $reloadable_only -eq 1; and echo "Only automations/dashboards/themes changed: Developer tools > YAML can reload these without a restart."

    if not set -q _flag_yes
        read -l -P "Restart Home Assistant now? [y/N] " answer
        if not string match -qri '^y(es)?$' -- $answer
            echo "Not restarting. The new config is on the volume and loads at the next restart."
            return 0
        end
    end

    echo "==> restarting Home Assistant"
    command kubectl -n $ns rollout restart deploy/homeassistant; or return 1
    command kubectl -n $ns rollout status deploy/homeassistant --timeout=300s; or begin
        echo "hass_deploy: the rollout did not finish in 5 minutes; check the pod" >&2
        return 1
    end
    echo "Home Assistant restarted."
end
