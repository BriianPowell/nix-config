function k3s_kubeconfig -d 'Fetch the k3s kubeconfig from a server node and merge it into ~/.kube/config'
    # Reference: https://docs.k3s.io/cluster-access
    argparse h/help 'H/host=' 'n/name=' 'o/output=' s/switch -- $argv; or return 1

    if set -q _flag_help
        echo "Usage: k3s_kubeconfig [-H host] [-n context-name] [-o file] [-s]"
        echo
        echo "  -H, --host    ssh host to fetch from (default: sheol)"
        echo "  -n, --name    context/cluster/user name to use (default: k3s-collective)"
        echo "  -o, --output  kubeconfig to merge into (default: ~/.kube/config)"
        echo "  -s, --switch  make the new context current (default: leave current-context alone)"
        return 0
    end

    set -q _flag_host; or set _flag_host sheol
    set -q _flag_name; or set _flag_name k3s-collective
    set -q _flag_output; or set _flag_output ~/.kube/config

    # k3s creates the kubeconfig as root:root 0600. If the ssh user can already read
    # it (sheol's copy was chowned to boog by hand), a plain scp is enough. Otherwise
    # it is staged in the ssh user's home (not /tmp) after a sudo copy. sudo needs a
    # TTY for the password prompt, hence ssh -t; that also means the file cannot be
    # piped over stdout.
    set -l remote_stage .k3s-kubeconfig.tmp
    set -l remote_src /etc/rancher/k3s/k3s.yaml

    # Use whatever address ssh_config maps the host to, since the file says 127.0.0.1.
    set -l addr (command ssh -G $_flag_host 2>/dev/null | string match -rg '^hostname (\S+)')
    if test -z "$addr"
        echo "k3s_kubeconfig: could not resolve a hostname for '$_flag_host' from ssh config" >&2
        return 1
    end

    set -l tmp (mktemp -t k3s-kubeconfig.XXXXXX); or return 1
    chmod 600 $tmp

    if command scp -q $_flag_host:$remote_src $tmp 2>/dev/null
        echo "Fetched $remote_src from $_flag_host directly"
    else
        echo "Cannot read $remote_src as the ssh user; staging with sudo on $_flag_host (password may be requested)..."
        if not command ssh -t $_flag_host "sudo install -m 600 -o \$USER $remote_src $remote_stage"
            echo "k3s_kubeconfig: failed to stage $remote_src on $_flag_host" >&2
            command rm -f $tmp
            return 1
        end

        command scp -q $_flag_host:$remote_stage $tmp
        set -l scp_status $status
        # Always remove the staged copy, even if scp failed.
        command ssh $_flag_host "rm -f $remote_stage"
        if test $scp_status -ne 0
            echo "k3s_kubeconfig: scp from $_flag_host failed" >&2
            command rm -f $tmp
            return 1
        end
    end

    # Point at the node instead of loopback, and replace k3s's generic "default"
    # names so this does not collide with another cluster's context.
    string replace -r -- 'https://127\.0\.0\.1:' "https://$addr:" <$tmp \
        | string replace -r -- '^(\s*(?:- )?(?:name|cluster|user|current-context): )default$' '${1}'$_flag_name \
        >$tmp.new
    command mv $tmp.new $tmp

    if not string match -q -r -- "server: https://$addr:" <$tmp
        echo "k3s_kubeconfig: fetched file does not look like a kubeconfig; leaving $_flag_output untouched" >&2
        command rm -f $tmp
        return 1
    end

    # `command` because mkdir is wrapped by a function that also cds into the new directory.
    command mkdir -p (dirname $_flag_output)
    set -l merged (mktemp -t k3s-kubeconfig-merged.XXXXXX)
    chmod 600 $merged

    # The new file comes first so its entries win if names ever collide.
    if test -f $_flag_output
        set -l backup $_flag_output.bak
        command cp -p $_flag_output $backup
        echo "Backed up existing config to $backup"

        # Work on a copy so the real file is only replaced once the merge succeeded.
        set -l base (mktemp -t k3s-kubeconfig-base.XXXXXX)
        chmod 600 $base
        command cp $_flag_output $base

        # Drop existing contexts that already point at this API server (typically a
        # copy of this same kubeconfig under another name, e.g. k3s's own "default"),
        # or the merge leaves the cluster in the file twice under different names.
        set -l new_server (KUBECONFIG=$tmp kubectl config view -o 'jsonpath={.clusters[0].cluster.server}')
        set -l cluster_servers (KUBECONFIG=$base kubectl config view -o 'jsonpath={range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}')
        set -l drop_clusters
        set -l drop_users
        for line in (KUBECONFIG=$base kubectl config view -o 'jsonpath={range .contexts[*]}{.name}{"\t"}{.context.cluster}{"\t"}{.context.user}{"\n"}{end}')
            set -l ctx (string split \t -- $line)
            test (count $ctx) -ge 2; or continue
            for entry in $cluster_servers
                set -l cs (string split \t -- $entry)
                if test "$cs[1]" = "$ctx[2]"; and test "$cs[2]" = "$new_server"
                    echo "Removing existing context '$ctx[1]': same server as the new one ($new_server)"
                    KUBECONFIG=$base kubectl config delete-context $ctx[1] >/dev/null 2>&1
                    set -a drop_clusters $ctx[2]
                    test (count $ctx) -ge 3; and set -a drop_users $ctx[3]
                end
            end
        end
        if test (count $drop_clusters) -gt 0
            # Only delete cluster/user entries that no remaining context still uses.
            set -l keep_clusters (KUBECONFIG=$base kubectl config view -o 'jsonpath={range .contexts[*]}{.context.cluster}{"\n"}{end}')
            set -l keep_users (KUBECONFIG=$base kubectl config view -o 'jsonpath={range .contexts[*]}{.context.user}{"\n"}{end}')
            for c in $drop_clusters
                contains -- $c $keep_clusters; or KUBECONFIG=$base kubectl config delete-cluster $c >/dev/null 2>&1
            end
            for u in $drop_users
                contains -- $u $keep_users; or KUBECONFIG=$base kubectl config unset users.$u >/dev/null 2>&1
            end
        end

        # kubectl leaves current-context dangling when its context is deleted, so
        # only keep it if it still exists; otherwise the new file's current wins.
        set -l current (KUBECONFIG=$base kubectl config current-context 2>/dev/null)
        contains -- $current (KUBECONFIG=$base kubectl config get-contexts -o name); or set current
        KUBECONFIG=$tmp:$base kubectl config view --flatten >$merged
        command rm -f $base
        if not set -q _flag_switch; and test -n "$current"
            KUBECONFIG=$merged kubectl config use-context $current >/dev/null
        end
    else
        command cp $tmp $merged
    end

    if test -s $merged
        command mv $merged $_flag_output
        chmod 600 $_flag_output
    else
        echo "k3s_kubeconfig: merge produced an empty file; leaving $_flag_output untouched" >&2
        command rm -f $tmp $merged
        return 1
    end
    command rm -f $tmp

    # KUBECONFIG is set explicitly so these act on the file we wrote, not whatever
    # the shell's default happens to be.
    if set -q _flag_switch
        KUBECONFIG=$_flag_output kubectl config use-context $_flag_name >/dev/null
    end

    echo "Merged context '$_flag_name' ($addr) into $_flag_output"
    echo "Current context: "(KUBECONFIG=$_flag_output kubectl config current-context)
end
