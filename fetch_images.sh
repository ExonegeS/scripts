#!/bin/bash

# Variables
APP_DIR="$HOME/applications/i3lock-fancy"
REPO_URL="https://api.github.com/repos/exoneges/scripts/contents/images"
IMAGE_LIST_FILE="$APP_DIR/images_list.txt"

# Fetch the list of images from the GitHub repo
IMAGE_LIST=$(curl -s "$REPO_URL" | jq -r '.[].name' | grep '\.png$')

# Check if there are any images
if [ -z "$IMAGE_LIST" ]; then
    echo "No images found in the repository."
    exit 1
fi

# Save the list of images to a file
echo "$IMAGE_LIST" > "$IMAGE_LIST_FILE"
echo "Fetched and saved image list to $IMAGE_LIST_FILE."

# Download all images
mkdir -p "$APP_DIR/usr/share/i3lock-fancy" # Create the directory if it doesn't exist
for IMAGE in $IMAGE_LIST; do
    LOCK_IMAGE_URL="https://raw.githubusercontent.com/exoneges/scripts/main/images/$IMAGE"
    wget "$LOCK_IMAGE_URL" -P "$APP_DIR/usr/share/images"
done

echo "Downloaded all images to $APP_DIR/usr/share/images"
