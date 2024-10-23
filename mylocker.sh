#!/bin/bash

# Check if a URL is provided, else use default
if [ $# -ne 1 ]; then
    echo "Usage: $0 <deb_file_url>"
    DEB_URL="ftp.de.debian.org/debian/pool/main/i/i3lock-fancy/i3lock-fancy_0.0~git20160228.0.0fcb933-3_amd64.deb"
else
    DEB_URL=$1
fi

# Variables
APP_DIR="$HOME/applications/i3lock-fancy"
DEB_FILE="${DEB_URL##*/}"
IMAGE_REPO_URL="https://api.github.com/repos/exoneges/scripts/contents/images" # Update with your GitHub username and repo
LOCK_IMAGE="$APP_DIR/usr/share/i3lock-fancy/lock.png"

# Create application directory if it doesn't exist
mkdir -p "$APP_DIR"

# Download the .deb file
wget "$DEB_URL" --directory-prefix="$HOME/applications"

# Extract the .deb file
dpkg-deb -x "$HOME/applications/$DEB_FILE" "$APP_DIR"

# Define the new SCRIPTPATH
NEW_SCRIPTPATH="SCRIPTPATH=\"$APP_DIR/usr/share/i3lock-fancy\""

# Modify the script file
SCRIPT_FILE="$APP_DIR/usr/bin/i3lock-fancy" # Adjust this if the script has a different name
if [ -f "$SCRIPT_FILE" ]; then
    sed -i.bak -E "s|^SCRIPTPATH=\".*\"|$NEW_SCRIPTPATH|" "$SCRIPT_FILE"
    echo "Updated SCRIPTPATH in $SCRIPT_FILE"
else
    echo "Script file not found: $SCRIPT_FILE"
fi

# Fetch the list of images from the GitHub repo
IMAGE_LIST=$(curl -s "$IMAGE_REPO_URL" | jq -r '.[].name' | grep '\.png$')

# Select a random image
SELECTED_IMAGE=$(echo "$IMAGE_LIST" | shuf -n 1)

# Download the selected lock image
LOCK_IMAGE_URL="https://raw.githubusercontent.com/exoneges/scripts/main/images/$SELECTED_IMAGE"
mkdir -p "$APP_DIR/usr/share/i3lock-fancy"
wget "$LOCK_IMAGE_URL" -O "$LOCK_IMAGE"

# Get dimensions of the lock image
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

# Set up an alias for mylock
ALIAS_COMMAND="alias mylock=\"$APP_DIR/usr/bin/i3lock-fancy\""
if ! grep -q "mylock" "$HOME/.bashrc"; then
    echo "$ALIAS_COMMAND" >> "$HOME/.bashrc"
    echo "Added alias mylock to ~/.bashrc. Please restart your terminal or run 'source ~/.bashrc' to apply."
else
    echo "Alias mylock already exists in ~/.bashrc."
fi
