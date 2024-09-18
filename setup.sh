#!/bin/sh -e

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Define the repository path and configuration file
REPO_DIR="$HOME/mylinux"
REPO_URL="https://github.com/dhruvmistry2000/mylinux"

# Check if the repository directory exists, create it if it doesn't
if [ ! -d "$REPO_DIR" ]; then
    echo "${YELLOW}Cloning mylinux repository into: $REPO_DIR${RC}"
    git clone "$REPO_URL" "$REPO_DIR"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully cloned mylinux repository${RC}"
    else
        echo "${RED}Failed to clone mylinux repository${RC}"
        exit 1
    fi
else
    echo "${GREEN}Repository already exists at: $REPO_DIR${RC}"
fi

# Define variables for commands and paths
PACKAGER=""
SUDO_CMD=""
SUGROUP=""
GITPATH="$REPO_DIR"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo "${GREEN}Using $pgm${RC}"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        echo "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "${GREEN}Using $SUDO_CMD as privilege escalation software${RC}"

    ## Check if the current directory is writable.
    GITPATH=$(dirname "$(realpath "$0")")
    if [ ! -w "$GITPATH" ]; then
        echo "${RED}Can't write to $GITPATH${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in $SUPERUSERGROUP; do
        if groups | grep -q "$sug"; then
            SUGROUP="$sug"
            echo "${GREEN}Super user group $SUGROUP${RC}"
            break
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep -q "$SUGROUP"; then
        echo "${RED}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar xorg xdg-user-dirs xorg-xinit arandr bat tree multitail fastfetch wget unzip fontconfig bspwm dconf dunst kitty thunar thunar-volman thunar-archive-plugin nitrogen picom base-devel git pulseaudio pulseaudio-alsa pulseaudio-bluetooth ly ranger bluez bluez-utils brightnessctl htop xf86-video-intel npm python3 python3-pip libconfig dbus libev libx11 libxcb libxext libgl libegl libepoxy meson pcre2 pixman uthash xcb-util-image xcb-util-renderutil xorgproto cmake libxft libimlib2 libxinerama libxcb-res xorg-xev xorg-xbacklight alsa-utils rofi polybar'

    echo "${YELLOW}Installing dependencies...${RC}"
    if [ "$PACKAGER" = "pacman" ]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "${YELLOW}Installing yay as AUR helper...${RC}"
            ${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
            if [ $? -eq 0 ]; then
                echo "${GREEN}Successfully installed yay${RC}"
            else
                echo "${RED}Failed to install yay${RC}"
                exit 1
            fi
        else
            echo "${GREEN}AUR helper already installed${RC}"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "${RED}No AUR helper found. Please install yay or paru.${RC}"
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    elif [ "$PACKAGER" = "nala" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    elif [ "$PACKAGER" = "emerge" ]; then
        ${SUDO_CMD} ${PACKAGER} -v app-shells/bash app-shells/bash-completion app-arch/tar sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    elif [ "$PACKAGER" = "xbps-install" ]; then
        ${SUDO_CMD} ${PACKAGER} -v ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    elif [[ "$PACKAGER" == "dnf" ]]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    else
        ${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed dependencies${RC}"
        else
            echo "${RED}Failed to install dependencies${RC}"
            exit 1
        fi
    fi

    # Give +x permission to bspwmrc and sxhkdrc files
    chmod +x "$HOME/.config/bspwm/bspwmrc"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully gave +x permission to bspwmrc${RC}"
    else
        echo "${RED}Failed to give +x permission to bspwmrc${RC}"
        exit 1
    fi
    chmod +x "$HOME/.config/sxhkd/sxhkdrc"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully gave +x permission to sxhkdrc${RC}"
    else
        echo "${RED}Failed to give +x permission to sxhkdrc${RC}"
        exit 1
    fi
}

installFont() {
    # Check to see if the FiraCode Nerd Font is installed (Change this to whatever font you would like)
    FONT_NAME="Hack"
    if fc-list :family | grep -iq "$FONT_NAME"; then
        echo "${GREEN}Font '$FONT_NAME' is installed.${RC}"
    else
        echo "${YELLOW}Installing font '$FONT_NAME'${RC}"
        # Change this URL to correspond with the correct font
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"
        FONT_DIR="$HOME/.local/share/fonts"
        wget $FONT_URL -O ${FONT_NAME}.zip
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully downloaded font '$FONT_NAME'${RC}"
        else
            echo "${RED}Failed to download font '$FONT_NAME'${RC}"
            exit 1
        fi
        unzip ${FONT_NAME}.zip -d $FONT_NAME
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully unzipped font '$FONT_NAME'${RC}"
        else
            echo "${RED}Failed to unzip font '$FONT_NAME'${RC}"
            exit 1
        fi
        mkdir -p $FONT_DIR
        mv ${FONT_NAME}/*.ttf $FONT_DIR/
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully moved font files to $FONT_DIR${RC}"
        else
            echo "${RED}Failed to move font files to $FONT_DIR${RC}"
            exit 1
        fi
        # Update the font cache
        fc-cache -fv
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully updated the font cache${RC}"
        else
            echo "${RED}Failed to update the font cache${RC}"
            exit 1
        fi
        # delete the files created from this
        rm -rf ${FONT_NAME} ${FONT_NAME}.zip
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully deleted temporary font files${RC}"
        else
            echo "${RED}Failed to delete temporary font files${RC}"
            exit 1
        fi
        echo "${GREEN}'$FONT_NAME' installed successfully.${RC}"
    fi
}

moveConfigs() {
    # Define the source and target directories for config files
    CONFIG_SRC_DIR="$GITPATH/configs"
    CONFIG_DEST_DIR="$HOME/.config"

    # Create the target directory if it doesn't exist
    mkdir -p "$CONFIG_DEST_DIR"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Successfully created target directory $CONFIG_DEST_DIR${RC}"
    else
        echo "${RED}Failed to create target directory $CONFIG_DEST_DIR${RC}"
        exit 1
    fi

    # Copy all config files from the source directory to the target directory
    for config in "$CONFIG_SRC_DIR"/*; do
        # Check if it's a file
        if [ -f "$config" ]; then
            # Copy the file to the destination directory
            cp "$config" "$CONFIG_DEST_DIR/"
            if [ $? -eq 0 ]; then
                echo "${GREEN}Copied config file $(basename "$config") to $CONFIG_DEST_DIR${RC}"
            else
                echo "${RED}Failed to copy config file $(basename "$config") to $CONFIG_DEST_DIR${RC}"
                exit 1
            fi
        fi
    done
}

copyWallpapers() {
    # Define the source and target directories for wallpapers
    WALLPAPER_SRC_DIR="$GITPATH/wallpaper"
    WALLPAPER_DEST_DIR="$HOME/wallpaper"

    # Copy the entire wallpapers directory to the home directory
    cp -r "$WALLPAPER_SRC_DIR" "$WALLPAPER_DEST_DIR"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Copied wallpapers directory to $WALLPAPER_DEST_DIR${RC}"
    else
        echo "${RED}Failed to copy wallpapers directory to $WALLPAPER_DEST_DIR${RC}"
        exit 1
    fi
}

setupXorg() {
    # Create .xinitrc file to start xorg with bspwm
    XINITRC="$HOME/.xinitrc"
    echo "exec bspwm" > "$XINITRC"
    if [ $? -eq 0 ]; then
        echo "${GREEN}Created $XINITRC to start xorg with bspwm${RC}"
    else
        echo "${RED}Failed to create $XINITRC to start xorg with bspwm${RC}"
        exit 1
    fi
}

checkEnv
installDepend
moveConfigs
copyWallpapers
setupXorg
installFont