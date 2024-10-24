#!/bin/bash

# Variables
APP_DIR="$HOME/applications/i3lock-fancy"
SCRIPT_FILE="$APP_DIR/usr/bin/i3lock-fancy"
REPO_URL="https://api.github.com/repos/exoneges/scripts/contents/images" 
LOCK_IMAGE="$HOME/applications/i3lock-fancy/usr/share/i3lock-fancy/lock.png"
MIN_WIDTH=360

# Fetch the list of images from the GitHub repo
IMAGE_LIST=$(curl -s "$REPO_URL" | jq -r '.[].name' | grep '\.png$')

# Check if there are any images
if [ -z "$IMAGE_LIST" ]; then
    echo "No images found in the repository."
    exit 1
fi

# Select a random image
SELECTED_IMAGE=$(echo "$IMAGE_LIST" | shuf -n 1)

# Download the selected lock image
LOCK_IMAGE_URL="https://raw.githubusercontent.com/exoneges/scripts/main/images/$SELECTED_IMAGE"
mkdir -p "$(dirname "$LOCK_IMAGE")" # Create the directory if it doesn't exist
wget "$LOCK_IMAGE_URL" -O "$LOCK_IMAGE"

echo "Downloaded random image: $SELECTED_IMAGE to $LOCK_IMAGE"

# Get dimensions of the lock image
LOCK_WIDTH=$(identify -format "%w" "$LOCK_IMAGE")
LOCK_HEIGHT=$(identify -format "%h" "$LOCK_IMAGE")

# Check if the image width is less than the minimum width
if [ "$LOCK_WIDTH" -lt "$MIN_WIDTH" ]; then
    # Resize the image to minimum width while preserving aspect ratio
    convert "$LOCK_IMAGE" -resize "${MIN_WIDTH}x" "$LOCK_IMAGE"
    echo "Resized image to minimum width of $MIN_WIDTH pixels."
fi

# Update the dimensions after resizing
LOCK_WIDTH=$(identify -format "%w" "$LOCK_IMAGE")
LOCK_HEIGHT=$(identify -format "%h" "$LOCK_IMAGE")

# Adjust positions based on the dimensions of the lock image
POSITION_X=$LOCK_WIDTH
POSITION_Y=$LOCK_HEIGHT

# Update the i3lock-fancy script to use the dynamic positions
if [ -f "$SCRIPT_FILE" ]; then
    sed -i.bak "s|MIDXi=\\(.*\\)|MIDXi=\$((\$W / 2 + \$Xoff - $POSITION_X / 2))|" "$SCRIPT_FILE"
    sed -i.bak "s|MIDYi=\\(.*\\)|MIDYi=\$((\$H / 2 + \$Yoff - $POSITION_Y / 2))|" "$SCRIPT_FILE"
    echo "Updated position calculations in $SCRIPT_FILE"
else
    echo "Script file not found: $SCRIPT_FILE"
fi

# Lock the screen
/home/student/applications/i3lock-fancy/usr/bin/i3lock-fancy
