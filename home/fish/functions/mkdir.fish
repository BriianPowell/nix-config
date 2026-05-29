function mkdir -d "Create a directory and set CWD"
    argparse -i 'm-mode=' 'p-parents' -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Error: No directory name provided" >&2
        return 1
    end

    set -l mkdir_args -p
    if set -q _flag_mode
        set -a mkdir_args -m $_flag_mode
    end

    if command mkdir $mkdir_args -- $argv
        set -l target_dir $argv[-1]

        if test -d "$target_dir"
            echo "Created and entering directory: $target_dir"
            cd "$target_dir"

            if command -v eza >/dev/null
                eza --long --all --group-directories-first
            else
                ls -lha
            end
        else
            echo "Directory created but couldn't access: $target_dir" >&2
            return 1
        end
    else
        echo "Error: Failed to create directory" >&2
        return 1
    end
end
