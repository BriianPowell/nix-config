function git_feature_branch_prepend -d 'Detect prepend of feature branches of git repository'
    command git rev-parse --git-dir &>/dev/null || return

    # Define prefixes in order of priority (first match wins)
    set -l prefixes feat feature fix story task bugfix hotfix chore docs refactor test ci cd

    set -l git_refs (git show-ref)

    for prefix in $prefixes
        if string match -q "*/$prefix/*" $git_refs
            echo $prefix
            return
        end
    end


    # Default fallback
    echo feature
end
