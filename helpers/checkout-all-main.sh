# Script to checkout all the services in the project to the main branch.
# --force to force checkout even if there are uncommitted changes by stashing them first.

FORCE_CHECKOUT=$1
PROJECT_ROOT="$(PWD)/../.."

# List directories in the project root that contain a .git folder (indicating they are git repositories)
SERVICES=$(find "$PROJECT_ROOT" -maxdepth 1 -type d -exec test -d "{}/.git" \; -print | sed 's|.*/||')

IGNORE_SERVICES=(".github")

for SERVICE in $SERVICES; do

  SERVICE_DIR="$PROJECT_ROOT/$SERVICE"

  cd "$SERVICE_DIR" || { echo "Failed to change directory to $SERVICE_DIR"; exit 1; }

  if [ "$FORCE_CHECKOUT" == "--force" ]; then
    git stash push -m "Auto-stash before checkout" > /dev/null 2>&1
    git checkout main > /dev/null 2>&1 || { echo "Failed to checkout main branch for $SERVICE"; exit 1; }
    git stash pop > /dev/null 2>&1
  else
    git checkout main > /dev/null 2>&1 || { echo "Failed to checkout main branch for $SERVICE"; exit 1; }
  fi

  echo "✅ Checked out $SERVICE to main branch."
done