# Script to zip the service folder without the files and directories specified in the `.zipignore` file. 
# The .zipignore file located as a sibling to this script, contains a list of files and directories to be excluded from the zip file.

SERVICE_NAME=$1
if [ -z "$SERVICE_NAME" ]; then
  echo "Error: Service name is required."
  exit 1
fi

PROJECT_ROOT="$(PWD)/../.."
SERVICE_DIR="$PROJECT_ROOT/$SERVICE_NAME"

if [ ! -d "$SERVICE_DIR" ]; then
  echo "🔴 Error: Service directory does not exist."
  exit 1
fi

ZIPIGNORE_FILE="$(PWD)/.zipignore"
if [ ! -f "$ZIPIGNORE_FILE" ]; then
  echo "🔴 Error: .zipignore file not found in the project root."
  exit 1
fi

TARGET_ZIP_FILE="$PROJECT_ROOT/$SERVICE_NAME.zip"

if [ -f "$TARGET_ZIP_FILE" ]; then
  echo "⚠️ Warning: Zip file already exists. It will be overwritten."
  rm "$TARGET_ZIP_FILE"
fi

zip -r $TARGET_ZIP_FILE "$SERVICE_DIR" -x $(cat "$ZIPIGNORE_FILE" | tr '\n' ' ') > /dev/null

cd $SERVICE_DIR
echo "✅ Service folder zipped successfully."
echo "Location: $TARGET_ZIP_FILE"
echo "Zip Size: $(du -h "$TARGET_ZIP_FILE" | cut -f1)"
echo "Current branch: $(git branch --show-current)"
