#!/bin/bash -e

# Define color variables
RC='\033[0m'        # Reset
GREEN='\033[32m'    # Green
YELLOW='\033[33m'   # Yellow
BLUE='\033[34m'     # Blue
RED='\033[31m'      # Red

REPO_URL="https://github.com/vinceliuice/Graphite-gtk-theme.git"
DIR_NAME="$HOME/Github/Graphite-gtk-theme"

if [ ! -d "$DIR_NAME" ]; then
    echo -e "${GREEN}Cloning repository...${RC}"
    git clone "$REPO_URL" "$DIR_NAME"
fi
cd "$DIR_NAME"
if [ -f "install.sh" ]; then
    echo -e "${BLUE}Running installation script...${RC}"
    chmod +x install.sh
    ./install.sh --tweaks nord darker rimless
else
    echo -e "${RED}install.sh not found in $DIR_NAME${RC}"
fi
echo -e "${GREEN}Cleaning up...${RC}"
cd ..
rm -rf "$DIR_NAME"