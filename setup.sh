#!/bin/sh -e

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Define the repository path and configuration file
REPO_DIR="$HOME/Github/mylinux"
REPO_URL="https://github.com/dhruvmistry2000/mylinux"

# Check if the repository directory exists, create it if it doesn't
if [ -d "$REPO_DIR" ]; then
    printf "${YELLOW}Pulling mylinux repository at: $REPO_DIR${RC}\n"
    cd "$REPO_DIR"
    git pull
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully pulled mylinux repository${RC}\n"
    else
        printf "${RED}Failed to pull mylinux repository${RC}\n"
        exit 1
    fi
else
    printf "${YELLOW}Cloning mylinux repository into: $REPO_DIR${RC}\n"
    git clone "$REPO_URL" "$REPO_DIR"
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully cloned mylinux repository${RC}\n"
    else
        printf "${RED}Failed to clone mylinux repository${RC}\n"
        exit 1
    fi
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
            printf "${RED}To run me, you need: $REQUIREMENTS${RC}\n"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='nala apt dnf pacman'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            printf "${GREEN}Using $pgm${RC}\n"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        printf "${RED}Can't find a supported package manager${RC}\n"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    printf "${GREEN}Using $SUDO_CMD as privilege escalation software${RC}\n"

    ## Check if the current directory is writable.
    GITPATH=$(dirname "$(realpath "$0")")
    if [ ! -w "$GITPATH" ]; then
        printf "${RED}Can't write to $GITPATH${RC}\n"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in $SUPERUSERGROUP; do
        if groups | grep -q "$sug"; then
            SUGROUP="$sug"
            printf "${GREEN}Super user group $SUGROUP${RC}\n"
            break
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep -q "$SUGROUP"; then
        printf "${RED}You need to be a member of the sudo group to run me!${RC}\n"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
      ## Check for dependencies based on the package manager.
    if [ "$PACKAGER" = "pacman" ]; then
        DEPENDENCIES='arandr xorg ntfs-3g bat btop tree xarchiver flameshot fastfetch wget nvtop unzip bspwm dconf dunst kitty nautilus thunar-volman thunar-archive-plugin nitrogen picom git ly yazi bluez bluez-utils brightnessctl htop npm python3-pip libconfig dbus libev meson pcre2 pixman uthash xcb-util-image xcb-util-renderutil cmake libxft libimlib2 libxinerama libxcb-res xorg-xev xorg-xbacklight alsa-utils rofi polybar sxhkd tldr vim nwg-look fzf materia-gtk-theme'
    elif [ "$PACKAGER" = "nala" ] || [ "$PACKAGER" = "apt" ]; then
        DEPENDENCIES='bspwm xorg sxhkd btop picom xarchiver flameshot kitty polybar rofi thunar nvtop thunar-archive-plugin thunar-volman nitrogen htop brightnessctl dunst git cmake meson npm python3 python3-pip  fontconfig fzf vim materia-gtk-theme'
    elif [ "$PACKAGER" = "dnf" ]; then
        DEPENDENCIES='bspwm xorg sxhkd btop picom xarchiver flameshot kitty polybar rofi thunar nvtop thunar-archive-plugin thunar-volman nitrogen htop brightnessctl dunst git gcc cmake meson npm python3 python3-pip dconf tldr vim fontconfig nwg-look fzf materia-gtk-theme'
    else
        printf "${RED}Unsupported package manager: $PACKAGER${RC}\n"
        exit 1
    fi

    printf "${YELLOW}Installing dependencies...${RC}\n"
    if [ "$PACKAGER" = "pacman" ]; then
        if ! command_exists yay && ! command_exists paru; then
            printf "${YELLOW}Installing yay as AUR helper...${RC}\n"
            ${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel
            cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
            if [ $? -eq 0 ]; then
                printf "${GREEN}Successfully installed yay${RC}\n"
            else
                printf "${RED}Failed to install yay${RC}\n"
                exit 1
            fi
        else
            printf "${GREEN}AUR helper already installed${RC}\n"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            printf "${RED}No AUR helper found. Please install yay or paru.${RC}\n"
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully installed dependencies${RC}\n"
        else
            printf "${RED}Failed to install dependencies${RC}\n"
            exit 1
        fi
    elif [ "$PACKAGER" = "nala" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully installed dependencies${RC}\n"
        else
            printf "${RED}Failed to install dependencies${RC}\n"
            exit 1
        fi
    elif [ "$PACKAGER" = "dnf" ]; then
        ${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully installed dependencies${RC}\n"
        else
            printf "${RED}Failed to install dependencies${RC}\n"
            exit 1
        fi
    else
        ${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully installed dependencies${RC}\n"
        else
            printf "${RED}Failed to install dependencies${RC}\n"
            exit 1
        fi
    fi

    ## Enable ly
    if command_exists ly; then
        printf "${GREEN}ly already installed${RC}\n"
    else
        printf "${YELLOW}Installing ly...${RC}\n"
        if [ "$PACKAGER" = "pacman" ]; then
            ${SUDO_CMD} ${PACKAGER} --noconfirm -S ly
        elif [ "$PACKAGER" = "dnf" ]; then
            ${SUDO_CMD} ${PACKAGER} install -y ly
        else
            printf "${RED}Unsupported package manager: $PACKAGER${RC}\n"
            exit 1
        fi
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully installed ly${RC}\n"
        else
            printf "${RED}Failed to install ly${RC}\n"
            exit 1
        fi
    fi

    sudo systemctl enable ly
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully enabled ly${RC}\n"
    else
        printf "${RED}Failed to enable ly${RC}\n"
        exit 1
    fi
}

installFont() {
    # Check to see if the FiraCode Nerd Font is installed (Change this to whatever font you would like)
    FONT_NAME="Hack"
    if fc-list :family | grep -iq "$FONT_NAME"; then
        printf "${GREEN}Font '$FONT_NAME' is installed.${RC}\n"
    else
        printf "${YELLOW}Installing font '$FONT_NAME'${RC}\n"
        # Change this URL to correspond with the correct font
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"
        FONT_DIR="$HOME/.local/share/fonts"
        wget $FONT_URL -O ${FONT_NAME}.zip
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully downloaded font '$FONT_NAME'${RC}\n"
        else
            printf "${RED}Failed to download font '$FONT_NAME'${RC}\n"
            exit 1
        fi
        unzip ${FONT_NAME}.zip -d $FONT_NAME
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully unzipped font '$FONT_NAME'${RC}\n"
        else
            printf "${RED}Failed to unzip font '$FONT_NAME'${RC}\n"
            exit 1
        fi
        mkdir -p $FONT_DIR
        mv ${FONT_NAME}/*.ttf $FONT_DIR/
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully moved font files to $FONT_DIR${RC}\n"
        else
            printf "${RED}Failed to move font files to $FONT_DIR${RC}\n"
            exit 1
        fi
        # Update the font cache
        fc-cache -fv
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully updated the font cache${RC}\n"
        else
            printf "${RED}Failed to update the font cache${RC}\n"
            exit 1
        fi
        # delete the files created from this
        rm -rf ${FONT_NAME} ${FONT_NAME}.zip
        if [ $? -eq 0 ]; then
            printf "${GREEN}Successfully deleted temporary font files${RC}\n"
        else
            printf "${RED}Failed to delete temporary font files${RC}\n"
            exit 1
        fi
        printf "${GREEN}'$FONT_NAME' installed successfully.${RC}\n"
    fi
}
moveConfigs() {
    # Define the source and target directories for config files
    CONFIG_SRC_DIR="$GITPATH/config"
    CONFIG_DEST_DIR="$HOME/.config"

    # Create the target directory if it doesn't exist
    mkdir -p "$CONFIG_DEST_DIR"
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully created target directory $CONFIG_DEST_DIR${RC}\n"
    else
        printf "${RED}Failed to create target directory $CONFIG_DEST_DIR${RC}\n"
        exit 1
    fi

    # Copy all config files from the source directory to the target directory
    for config in "$CONFIG_SRC_DIR"/*; do
        # Check if it's a directory
        if [ -d "$config" ]; then
            # Copy the directory to the destination directory
            cp -r "$config" "$CONFIG_DEST_DIR/"
            if [ $? -eq 0 ]; then
                printf "${GREEN}Copied config directory $(basename "$config") to $CONFIG_DEST_DIR${RC}\n"
            else
                printf "${RED}Failed to copy config directory $(basename "$config") to $CONFIG_DEST_DIR${RC}\n"
                exit 1
            fi
        fi
    done

    # Give +x permission to bspwmrc and sxhkdrc files
    chmod +x "$HOME/.config/bspwm/bspwmrc"
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully gave +x permission to bspwmrc${RC}\n"
    else
        printf "${RED}Failed to give +x permission to bspwmrc${RC}\n"
        exit 1
    fi
    chmod +x "$HOME/.config/sxhkd/sxhkdrc"
    if [ $? -eq 0 ]; then
        printf "${GREEN}Successfully gave +x permission to sxhkdrc${RC}\n"
    else
        printf "${RED}Failed to give +x permission to sxhkdrc${RC}\n"
        exit 1
    fi
}

setupXorg() {
    # Create .xinitrc file to start xorg with bspwm and sxhkd
    XINITRC="$HOME/.xinitrc"
    echo "sxhkd &" > "$XINITRC"
    echo "exec bspwm" >> "$XINITRC"
    if [ $? -eq 0 ]; then
        printf "${GREEN}Created $XINITRC to start xorg with bspwm and sxhkd${RC}\n"
    else
        printf "${RED}Failed to create $XINITRC to start xorg with bspwm and sxhkd${RC}\n"
        exit 1
    fi
}

picom_animations() {
    # Check if picom is already installed
    if ! command -v picom &> /dev/null; then
        # Clone the repository in the home/build directory
        mkdir -p build
        if [ ! -d build/picom ]; then
            if ! git clone https://github.com/FT-Labs/picom.git build/picom; then
                printf "Failed to clone the repository\n"
                return 1
            fi
        else
            printf "Repository already exists, skipping clone\n"
        fi

        cd build/picom || { printf "Failed to change directory to picom"; return 1; }

        # Build the project
        if ! meson setup --buildtype=release build; then
            printf "Meson setup failed\n"
            return 1
        fi

        if ! ninja -C build; then
            printf "Ninja build failed\n"
            return 1
        fi

        # Install the built binary
        if ! sudo ninja -C build install; then
            printf "Failed to install the built binary\n"
            return 1
        fi

        # Clean up the build directory
        cd ..
        if [ -d build ]; then
            rm -rf build
        fi

        printf "Picom animations installed successfully\n"
    else
        printf "Picom is already installed\n"
    fi
}
installMyBashConfig() {
    curl -sSL https://raw.githubusercontent.com/dhruvmistry2000/mybash/master/setup.sh | bash
    if [ $? -eq 0 ]; then
        printf "${GREEN}My Bash configuration installed successfully!${RC}\n"
    else
        printf "${RED}Failed to install My Bash configuration.${RC}\n"
    fi
}
copyVimrc() {
    if [ -f "$REPO_DIR/.vimrc" ]; then
        cp "$REPO_DIR/.vimrc" "$HOME/.vimrc"
        printf "${GREEN}.vimrc copied to $HOME successfully!${RC}\n"
    else
        printf "${RED}.vimrc not found in $REPO_DIR${RC}\n"
    fi
}


checkEnv
installDepend
moveConfigs
setupXorg
installFont
picom_animations
installMyBashConfig
copyVimrc