#!/bin/bash

# Variables
APP_DIR="$HOME/applications/i3lock-fancy"
SCRIPT_FILE="$APP_DIR/usr/bin/i3lock-fancy"
LOCK_IMAGE="$APP_DIR/usr/share/i3lock-fancy/lock.png"
MIN_WIDTH=360
IMAGE_LIST_FILE="$APP_DIR/images_list.txt"

# Check if the image list file exists
if [ ! -f "$IMAGE_LIST_FILE" ]; then
    echo "Image list file not found. Please run fetch_images.sh first."
    exit 1
fi

# Select a random image from the local directory
SELECTED_IMAGE=$(shuf -n 1 "$IMAGE_LIST_FILE")

# Set the lock image path directly from the selected image
LOCK_IMAGE="$APP_DIR/usr/share/images/$SELECTED_IMAGE"

# Check if the selected image exists
if [ ! -f "$LOCK_IMAGE" ]; then
    echo "Selected image not found: $LOCK_IMAGE"
    exit 1
fi

echo "Using random image: $SELECTED_IMAGE for lock screen."

cp $LOCK_IMAGE "$APP_DIR/usr/share/i3lock-fancy/lock.png"


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
