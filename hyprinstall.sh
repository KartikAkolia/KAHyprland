#!/bin/bash

# Define variables for colored output
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

# Function to print error messages
print_error() {
    printf "%s %s\n" "$RED" "$1" >&2
}

# Function to print success messages
print_success() {
    printf "%s %s\n" "$GREEN" "$1"
}

# Function to check and install dependencies
install_dependencies() {
    local dependencies=("$@")  # Accepts a list of dependencies as arguments

    for pkg in "${dependencies[@]}"; do
        # Check if it's an AUR package
        if [[ "$pkg" =~ ^[a-zA-Z0-9_-]+-git$ ]] || [[ "$pkg" == "yay" ]]; then
            # Check if yay or paru is installed
            if command -v yay &> /dev/null; then
                aur_helper="yay"
            elif command -v paru &> /dev/null; then
                aur_helper="paru"
            else
                print_error "Neither yay nor paru found. Installing yay..."
                git clone https://aur.archlinux.org/yay-bin.git
                cd yay-bin
                makepkg -si --noconfirm
                cd ..
                rm -rf yay-bin
                aur_helper="yay"
            fi

            # Install the AUR package if not already installed
            if ! $aur_helper -Qi "$pkg" &> /dev/null; then
                print_error "$pkg not found. Installing $pkg..."
                $aur_helper -S --noconfirm "$pkg" || {
                    print_error "Failed to install $pkg"
                    exit 1
                }
            else
                print_success "$pkg is already installed. Skipping installation."
            fi

        else
            # Otherwise, it's a pacman package
            if ! pacman -Qi "$pkg" &> /dev/null; then
                print_error "$pkg not found. Installing $pkg..."
                sudo pacman -Sy --noconfirm "$pkg" || {
                    print_error "Failed to install $pkg"
                    exit 1
                }
            else
                print_success "$pkg is already installed. Skipping installation."
            fi
        fi
    done
}

# Check for and install base dependencies
base_dependencies=("git" "wget" "unzip")
install_dependencies "${base_dependencies[@]}"

printf "$(tput setaf 2) Welcome to the Arch Linux Hyprland installer!\n $(tput sgr0)"

### Install Required Packages ###
read -n1 -rep "${CAT} Install required packages from README.md? (y/n)" inst_pkgs
if [[ $inst_pkgs =~ ^[Yy]$ ]]; then
    required_pkgs=("alacritty" "discord" "flameshot" "gparted" "google-chrome" "grimblast-git" \
                   "nwg-look" "pamixer" "papirus-icon-theme" "pavucontrol" "rsync" "rofi" "sddm-git" \
                   "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-shares-plugin" \
                   "thunar-vcs-plugin" "thunar-volman" "zoxide" "fzf" "swww" "p7zip")
    install_dependencies "${required_pkgs[@]}"
fi

### Install Hyprland Dependencies ###
read -n1 -rep "${CAT} Install Hyprland dependencies? (y/n)" inst_hypr
if [[ $inst_hypr =~ ^[Yy]$ ]]; then
    hyprland_dependencies=("aquamarine" "gdb" "hyprcursor" "hyprlang" "hyprutils-git" \
                           "hyprwayland-scanner" "libdisplay-info" "libfixes" "libinput" \
                           "libliftoff" "libxcb" "libxcomposite" "libxkbcommon" "libxrender" \
                           "meson" "ninja" "pango" "pixman" "seatd" "tomlplusplus" \
                           "wayland-protocols" "xcb-proto" "xcb-util" "xcb-util-errors" \
                           "xcb-util-keysyms" "xcb-util-wm" "xorg-xinput" "xorg-xwayland")
    install_dependencies "${hyprland_dependencies[@]}"
fi

### Install CMake and Build Hyprland ###
read -n1 -rep "${CAT} Install CMake and build Hyprland? (y/n)" inst_cmake
if [[ $inst_cmake =~ ^[Yy]$ ]]; then
    build_tools=("cmake" "make")
    install_dependencies "${build_tools[@]}"

    # Build Hyprland
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
    cd ..
    rm -rf Hyprland
fi

### Install Fonts ###
read -n1 -rep "${CAT} Install Meslo Nerd Font? (y/n)" inst_fonts
if [[ $inst_fonts =~ ^[Yy]$ ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_ZIP="$FONT_DIR/Meslo.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"

    # Check if Meslo Nerd-font is already installed
    if fc-list | grep -qi "Meslo"; then
        print_success "Meslo Nerd-fonts are already installed."
    else
        echo "Installing Meslo Nerd-fonts..."
        mkdir -p "$FONT_DIR"
        wget -O "$FONT_ZIP" "$FONT_URL" || {
            print_error "Failed to download Meslo Nerd-fonts from $FONT_URL"
            exit 1
        }
        unzip -o "$FONT_ZIP" -d "$FONT_DIR" || {
            print_error "Failed to unzip $FONT_ZIP"
            exit 1
        }
        rm "$FONT_ZIP"
        fc-cache -fv # Rebuild the font cache
        print_success "Meslo Nerd-fonts installed successfully."
    fi
fi

# Script completion
printf "\n${GREEN} Installation Completed.\n"

