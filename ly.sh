#!/bin/sh -e

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Define variables for commands and paths
PACKAGER=""
SUDO_CMD=""
LY_REPO_URL="https://github.com/fairyglade/ly.git"
LY_DIR="$HOME/ly"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='git curl zig'
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo -e "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo -e "${GREEN}Using $pgm${GREEN}"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo -e "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        echo -e "${RED}Neither sudo nor doas found. Please install one of them.${RC}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${RC}"
    $SUDO_CMD $PACKAGER install -y build-essential libpam0g-dev libxcb-xkb-dev git zig
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Dependencies installed successfully${RC}"
    else
        echo -e "${RED}Failed to install dependencies${RC}"
        exit 1
    fi
}

clone_and_build_ly() {
    if [ ! -d "$LY_DIR" ]; then
        echo -e "${YELLOW}Cloning ly repository into: $LY_DIR${RC}"
        git clone "$LY_REPO_URL" "$LY_DIR"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully cloned ly repository${RC}"
        else
            echo -e "${RED}Failed to clone ly repository${RC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Ly repository already exists at: $LY_DIR${RC}"
    fi

    cd "$LY_DIR"
    echo -e "${YELLOW}Building ly...${RC}"
    zig build
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Ly built successfully${RC}"
    else
        echo -e "${RED}Failed to build ly${RC}"
        exit 1
    fi

    echo -e "${YELLOW}Installing ly...${RC}"
    $SUDO_CMD zig build install
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Ly installed successfully${RC}"
    else
        echo -e "${RED}Failed to install ly${RC}"
        exit 1
    fi
}

enable_ly_service() {
    echo -e "${YELLOW}Enabling ly service...${RC}"
    $SUDO_CMD systemctl enable ly.service
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Ly service enabled successfully${RC}"
    else
        echo -e "${RED}Failed to enable ly service${RC}"
        exit 1
    fi
}


checkEnv
install_dependencies
clone_and_build_ly
enable_ly_service