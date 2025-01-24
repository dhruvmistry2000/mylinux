# Mylinux
[![Bash Lint](https://github.com/dhruvmistry2000/mylinux/actions/workflows/main.yml/badge.svg)](https://github.com/dhruvmistry2000/mylinux/actions/workflows/main.yml)

This project provides a streamlined approach to setting up a customizable Linux environment tailored for developers and power users. It features scripts that automate the cloning of the project repository, verify system dependencies, and install a curated list of essential packages based on the detected package manager. The project is designed to work seamlessly with various package managers, including pacman, nala, apt, and dnf, ensuring broad compatibility across different Linux distributions.

# Overview Image
![Project Overview](image.png)

### Key Packages Installed
The following key packages are installed as part of this project:
- bspwm
- sxhkd
- picom
- flameshot
- kitty
- polybar
- rofi
- thunar
- nitrogen
- htop
- brightnessctl
- dunst
- git
- dconf
- nwg-look

# Installation Instructions
To install and configure the project, execute the following command in your terminal:
```bash
curl -sSL https://raw.githubusercontent.com/dhruvmistry2000/mylinux/master/setup.sh | bash
```

# Customized Shortcuts
The following are some of the customized shortcuts defined in `config/sxhkd/sxhkdrc`:

- **Launch Terminal**: `Super + Return` 
- **Launch Browser**: `Super + b`
- **Switch Workspaces**: `Super + {1,2,3,...}`
- **Launch VS Code**: `Super + c`
- **Launch Brave**: `Super + n`
- **Launch Thunar(File manager)**: `Super + e`
- **Open App Drawer**: `Super + Space`
- **Take Screenshot**: `Super + Ctrl + f` 

These shortcuts enhance productivity and streamline workflow within the Linux environment.


