function gitclcd -d 'Clone a git repository and cd into it'
    # Check if URL is provided
    if test (count $argv) -eq 0
        echo "Usage: gitclcd <repository-url> [directory-name]"
        return 1
    end

    set -l repo_url $argv[1]
    set -l target_dir ""

    # If a second argument is provided, use it as the directory name
    if test (count $argv) -ge 2
        set target_dir $argv[2]
    else
        # Extract directory name from URL
        # Handle both SSH and HTTPS URLs
        set target_dir (string replace -r '.*/' '' $repo_url)
        set target_dir (string replace '.git' '' $target_dir)
    end

    # Clone the repository
    echo "Cloning $repo_url into $target_dir..."
    if git clone $repo_url $target_dir
        echo "Successfully cloned. Changing to directory: $target_dir"
        cd $target_dir
    else
        echo "Failed to clone repository"
        return 1
    end
end
