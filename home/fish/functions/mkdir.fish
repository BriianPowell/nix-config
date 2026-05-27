function mkdir -d "Create a directory and set CWD"
    # Check if any arguments provided
    if test (count $argv) -eq 0
        echo "Error: No directory name provided" >&2
        return 1
    end

    # Parse arguments to separate options from directory names
    set -l options
    set -l directories

    for arg in $argv
        if string match -q -- '-*' $arg
            set -a options $arg
        else
            set -a directories $arg
        end
    end

    # Ensure we have at least one directory to create
    if test (count $directories) -eq 0
        echo "Error: No directory name provided (only options found)" >&2
        return 1
    end

    # Always use -p flag for parent directory creation
    if not contains -- -p $options
        set -a options -p
    end

    # Create the directories
    if command mkdir $options $directories
        # Get the last directory that was specified (not an option)
        set -l target_dir $directories[-1]

        # Only cd if the directory was actually created and exists
        if test -d "$target_dir"
            echo "Created and entering directory: $target_dir"
            cd "$target_dir"

            # Optional: list contents of parent to show the new directory
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
