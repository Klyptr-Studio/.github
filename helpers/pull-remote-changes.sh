# Script to pull all remote changes from all the repositories

PROJECT_DIR="/Users/dharmaraj/Projects/klyptr-studio"

# Get the list of directories in the project directory and filter out only git repositories
REPO_DIRS=$(find "$PROJECT_DIR" -maxdepth 1 -type d -name ".git" -prune -o -type d -print)

# Iterate over each repository directory and pull the latest changes
for REPO_DIR in $REPO_DIRS; do
    # Check if the directory is a git repository
    if [ -d "$REPO_DIR/.git" ]; then
        REPO_NAME=$(basename "$REPO_DIR")
        echo "Pulling latest changes: $REPO_NAME"
        cd "$REPO_DIR" || continue
        git pull origin main > /dev/null 2>&1
    fi
done

echo "All remote changes pulled successfully."