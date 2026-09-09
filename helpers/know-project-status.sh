# Get project name argument from the command line
PROJECT_NAME="${1}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name argument is missing."
    echo "Usage: ./know-project-status.sh <project-name>"
    exit 1
fi

echo "======================================"
echo "=============== ISSUES ==============="
echo "======================================"
gh issue list --repo Klyptr-Studio/"$PROJECT_NAME"
echo ""

echo "======================================"
echo "============ PULL REQUESTS ==========="
echo "======================================"
gh pr list --repo Klyptr-Studio/"$PROJECT_NAME"
