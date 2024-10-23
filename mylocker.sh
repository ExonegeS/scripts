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
SCRIPT_FILE="$APP_DIR/usr/bin/i3lock-fancy"
DEB_FILE="${DEB_URL##*/}"

# Create application directory if it doesn't exist
mkdir -p "$APP_DIR"

# Download the .deb file
wget "$DEB_URL" --directory-prefix="$HOME/applications"

# Extract the .deb file
dpkg-deb -x "$HOME/applications/$DEB_FILE" "$APP_DIR"

# Define the new SCRIPTPATH
NEW_SCRIPTPATH="SCRIPTPATH=\"$APP_DIR/usr/share/i3lock-fancy\""

# Modify the script file
if [ -f "$SCRIPT_FILE" ]; then
    sed -i.bak -E "s|^SCRIPTPATH=\".*\"|$NEW_SCRIPTPATH|" "$SCRIPT_FILE"
    echo "Updated SCRIPTPATH in $SCRIPT_FILE"
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
