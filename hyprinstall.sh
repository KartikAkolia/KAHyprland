#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux Hyprland installer!\n $(tput sgr0)"
sleep 2

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!\nThis script will overwrite some of your configs and files!"
sleep 2

printf "\n$YELLOW Some commands require you to enter your password in order to execute.\nIf you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review the contents of this script.\n"
sleep 3

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" 
}

# Function to install a package and handle conflicts
install_package() {
    local pkg="$1"
    if ! sudo pacman -Sy --noconfirm "$pkg"; then
        # Check for conflict in the error message
        if pacman -Qi "$pkg" &> /dev/null; then
            print_error "$pkg installation failed due to a conflict. Attempting to resolve..."
            # Attempt to remove the conflicting package
            echo "Removing conflicting package..."
            sudo pacman -Rns "$pkg" || {
                print_error "Failed to remove $pkg. Please check manually."
                exit 1
            }
            # Retry installing the package
            if ! sudo pacman -Sy --noconfirm "$pkg"; then
                print_error "Failed to reinstall $pkg after resolving conflicts."
                exit 1
            fi
        else
            print_error "Failed to install $pkg due to an unknown error."
            exit 1
        fi
    else
        print_success "$pkg installed successfully."
    fi
}

# Check and install global dependencies
global_dependencies=("wget" "unzip" "fc-list")
for pkg in "${global_dependencies[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        print_error "$pkg not found. Installing $pkg..."
        install_package "$pkg"
    else
        print_success "$pkg is already installed. Skipping installation."
    fi
done

### Install Fonts ###
read -n1 -rep "${CAT} Install Meslo Nerd Font? (y/n) " inst_fonts
if [[ $inst_fonts =~ ^[Yy]$ ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_ZIP="$FONT_DIR/Meslo.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"

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

### Install Required Packages ###
read -n1 -rep "${CAT} Install required packages from README.md? (y/n) " inst_pkgs
if [[ $inst_pkgs =~ ^[Yy]$ ]]; then
    required_pkgs=("alacritty" "discord" "flameshot" "gparted" "google-chrome" "grimblast-git" \
    "nwg-look" "pamixer" "papirus-icon-theme" "pavucontrol" "rsync" "rofi" "sddm-git" \
    "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-shares-plugin" \
    "thunar-vcs-plugin" "thunar-volman" "zoxide" "fzf" "swww" "unzip" "p7zip")

    for pkg in "${required_pkgs[@]}"; do
        install_package "$pkg"
    done
else
    print_success "No packages installed from README.md."
fi

### Install Hyprland Dependencies ###
read -n1 -rep "${CAT} Install Hyprland dependencies? (y/n) " inst_hypr
if [[ $inst_hypr =~ ^[Yy]$ ]]; then
    hypr_dependencies=("aquamarine" "gdb" "hyprcursor" "hyprlang" "hyprutils-git" "hyprwayland-scanner" \
    "libdisplay-info" "libfixes" "libinput" "libliftoff" "libxcb" "libxcomposite" \
    "libxkbcommon" "libxrender" "meson" "ninja" "pango" "pixman" "seatd" \
    "tomlplusplus" "wayland-protocols" "xcb-proto" "xcb-util" "xcb-util-errors" \
    "xcb-util-keysyms" "xcb-util-wm" "xorg-xinput" "xorg-xwayland")

    for pkg in "${hypr_dependencies[@]}"; do
        install_package "$pkg"
    done
else
    print_success "No Hyprland dependencies installed."
fi

### Install CMake and Build Hyprland ###
read -n1 -rep "${CAT} Install CMake and build Hyprland? (y/n) " inst_hyprbuild
if [[ $inst_hyprbuild =~ ^[Yy]$ ]]; then
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
    print_success "Hyprland built and installed successfully."
    cd ..
else
    print_success "Skipped building Hyprland."
fi

### Install Starship ###
read -n1 -rep "${CAT} Install Starship? (y/n) " inst_starship
if [[ $inst_starship =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh
    echo -e "\neval \"\$(starship init bash)\"" >> ~/.bashrc
    echo -e "eval \"\$(zoxide init bash)\"" >> ~/.bashrc
    print_success "Starship installed and configured."
else
    print_success "Starship installation skipped."
fi

### Enable SDDM Autologin ###
read -n1 -rep "${CAT} Would you like to enable SDDM autologin? (y,n) " SDDM
if [[ $SDDM =~ ^[Yy]$ ]]; then
    LOC="/etc/sddm.conf"
    echo -e "The following has been added to $LOC.\n"
    echo -e "[Autologin]\nUser = $(whoami)\nSession=hyprland" | sudo tee -a $LOC
    echo -e "\nEnabling SDDM service...\n"
    sudo systemctl enable sddm
    sleep 3
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n) " BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    blue_pkgs=("bluez" "bluez-utils" "blueman")
    for pkg in "${blue_pkgs[@]}"; do
        install_package "$pkg"
    done
    printf "Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
else
    printf "${YELLOW} No Bluetooth packages installed..\n"
fi

# Script Completion
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n) " HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
        print_error "Hyprland not found. Please make sure Hyprland is installed by checking install.log."
        exit 1
    fi
else
    exit
fi
