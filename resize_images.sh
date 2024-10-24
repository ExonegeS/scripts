#!/bin/bash

# Variables
APP_DIR="$HOME/applications/i3lock-fancy"
IMAGE_DIR="$APP_DIR/usr/share/images"
MIN_WIDTH=1000

# Check if the image directory exists
if [ ! -d "$IMAGE_DIR" ]; then
    echo "Image directory not found: $IMAGE_DIR"
    exit 1
fi

# Iterate through all PNG images in the image directory
for LOCK_IMAGE in "$IMAGE_DIR"/*.png; do
    # Check if the file exists
    if [ ! -f "$LOCK_IMAGE" ]; then
        echo "No PNG images found in $IMAGE_DIR."
        exit 1
    fi

    # Get dimensions of the lock image
    LOCK_WIDTH=$(identify -format "%w" "$LOCK_IMAGE")

    # Check if the image width is less than the minimum width
    if [ "$LOCK_WIDTH" -lt "$MIN_WIDTH" ]; then
        # Resize the image to minimum width while preserving aspect ratio
        convert "$LOCK_IMAGE" -resize "${MIN_WIDTH}x" "$LOCK_IMAGE"
        echo "Resized image: $(basename "$LOCK_IMAGE") to minimum width of $MIN_WIDTH pixels."
    else
        echo "Image: $(basename "$LOCK_IMAGE") is already wide enough."
    fi
done

echo "All images have been processed."
