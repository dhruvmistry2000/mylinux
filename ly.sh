#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RC='\033[0m' # Reset color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to handle the installation of dependencies
install_dependencies() {
    DEPENDENCIES="git make gcc"
    if command_exists apt; then
        sudo apt update
        sudo apt install -y $DEPENDENCIES
    elif command_exists pacman; then
        sudo pacman --noconfirm -S $DEPENDENCIES
    elif command_exists dnf; then
        sudo dnf install -y $DEPENDENCIES
    else
        echo -e "${RED}Unsupported package manager${RC}"
        exit 1
    fi

    # Check if dependencies were installed successfully
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully installed dependencies${RC}"
    else
        echo -e "${RED}Failed to install dependencies${RC}"
        exit 1
    fi
}

# Function to install zig from tar file
install_zig() {
    if command_exists zig; then
        echo -e "${YELLOW}Zig is already installed${RC}"
    else
        ZIG_VERSION="0.14.0"
        ZIG_TAR="zig-linux-x86_64-$ZIG_VERSION.tar.xz"
        ZIG_URL="https://ziglang.org/download/$ZIG_TAR"

        curl -LO $ZIG_URL
        if [ $? -eq 0 ]; then
            tar -xf $ZIG_TAR
            sudo mv zig-linux-x86_64-$ZIG_VERSION /opt/zig
            sudo ln -s /opt/zig/zig /usr/local/bin/zig
            echo -e "${GREEN}Successfully installed zig${RC}"
            rm $ZIG_TAR
        else
            echo -e "${RED}Failed to download zig${RC}"
            exit 1
        fi
    fi
}

# Function to build and install ly display manager
build_and_install_ly() {
    cd ..
    if [ -d "ly" ]; then
        echo -e "${YELLOW}ly repository already exists. Pulling the latest changes...${RC}"
        cd ly
        git pull
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully pulled the latest changes${RC}"
        else
            echo -e "${RED}Failed to pull the latest changes${RC}"
            exit 1
        fi
    else
        # Clone the ly repository
        git clone --recurse-submodules https://github.com/fairyglade/ly.git
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully cloned ly repository${RC}"
        else
            echo -e "${RED}Failed to clone ly repository${RC}"
            exit 1
        fi
        cd ly
    fi

    # Build ly using zig
    zig build
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully built ly${RC}"
    else
        echo -e "${RED}Failed to build ly${RC}"
        exit 1
    fi

    # Install ly
    sudo zig build install
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully installed ly${RC}"
    else
        echo -e "${RED}Failed to install ly${RC}"
        exit 1
    fi

    # Clean up downloaded files
    cd ..
    rm -rf ly
}

# Main script execution
install_dependencies
install_zig
build_and_install_ly
