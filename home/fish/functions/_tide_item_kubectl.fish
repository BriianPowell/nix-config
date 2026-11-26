# Overrides tide's item: only show the kubectl context under the directories listed in
# $tide_kubectl_dirs (path substrings), so it isn't noise in unrelated repos.
function _tide_item_kubectl
    set -q tide_kubectl_dirs || return
    set -l here (pwd -P)
    set -l match 1
    for d in $tide_kubectl_dirs
        if string match -q -- "*/$d" $here || string match -q -- "*/$d/*" $here
            set match 0
            break
        end
    end
    test $match -eq 0 || return
    kubectl config view --minify --output 'jsonpath={.current-context}/{..namespace}' 2>/dev/null | read -l context &&
        _tide_print_item kubectl $tide_kubectl_icon' ' (string replace -r '/(|default)$' '' $context)
end
