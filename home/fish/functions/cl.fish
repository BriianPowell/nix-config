function cl -d "cd into directory and ls"
    # Default to home directory if no argument provided
    set -l target_dir $argv[1]
    if test -z "$target_dir"
        set target_dir ~
    end

    # Check if directory exists
    if not test -d "$target_dir"
        echo "Error: Directory '$target_dir' does not exist" >&2
        return 1
    end

    # Change directory and list contents
    if cd "$target_dir"
        # Use ls with colors and better formatting
        if command -v eza >/dev/null
            eza --long --all --group-directories-first
        else
            ls -lha
        end
    else
        echo "Error: Failed to change to directory '$target_dir'" >&2
        return 1
    end
end
