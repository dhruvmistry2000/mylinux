#!/bin/bash

# Define colors for output
RC='\033[0m'
RED='\033[31m'
GREEN='\033[32m'

# Define the source and target directories for config files
CONFIG_SRC_DIR="$HOME/Github/mylinux/config"
CONFIG_DEST_DIR="$HOME/.config"

# Create the target directory if it doesn't exist
if [ ! -d "$CONFIG_DEST_DIR" ]; then
    mkdir -p "$CONFIG_DEST_DIR"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully created target directory $CONFIG_DEST_DIR${RC}"
    else
        echo -e "${RED}Failed to create target directory $CONFIG_DEST_DIR${RC}"
        exit 1
    fi
else
    echo -e "${GREEN}Target directory $CONFIG_DEST_DIR already exists${RC}"
fi

# Copy all config files from the source directory to the target directory
if [ ! -d "$CONFIG_DEST_DIR/bspwm" ] || [ ! -d "$CONFIG_DEST_DIR/sxhkd" ]; then
    cp -r "$CONFIG_SRC_DIR"/* "$CONFIG_DEST_DIR/"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully copied config files to $CONFIG_DEST_DIR${RC}"
    else
        echo -e "${RED}Failed to copy config files to $CONFIG_DEST_DIR${RC}"
        exit 1
    fi
else
    echo -e "${GREEN}Config files already exist in $CONFIG_DEST_DIR${RC}"
fi

# Give +x permission to bspwmrc and sxhkdrc files
if [ ! -x "$CONFIG_DEST_DIR/bspwm/bspwmrc" ]; then
    chmod +x "$CONFIG_DEST_DIR/bspwm/bspwmrc"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully gave +x permission to bspwmrc${RC}"
    else
        echo -e "${RED}Failed to give +x permission to bspwmrc${RC}"
        exit 1
    fi
else
    echo -e "${GREEN}Bspwmrc already has +x permission${RC}"
fi

if [ ! -x "$CONFIG_DEST_DIR/sxhkd/sxhkdrc" ]; then
    chmod +x "$CONFIG_DEST_DIR/sxhkd/sxhkdrc"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully gave +x permission to sxhkdrc${RC}"
    else
        echo -e "${RED}Failed to give +x permission to sxhkdrc${RC}"
        exit 1
    fi
else
    echo -e "${GREEN}Sxhkdrc already has +x permission${RC}"
fi
