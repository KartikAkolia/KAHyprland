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
                echo "Neither yay nor paru found. Installing yay..."
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

### Install Required Packages ###
read -n1 -rep "${CAT} Install required packages from README.md? (y/n)" inst_pkgs
if [[ $inst_pkgs =~ ^[Yy]$ ]]; then
    required_pkgs=("alacritty" "discord" "flameshot" "gparted" "google-chrome" "grimblast-git" \
                   "nwg-look" "pamixer" "papirus-icon-theme" "pavucontrol" "rsync" "rofi" "sddm-git" \
                   "thunar" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-shares-plugin" \
                   "thunar-vcs-plugin" "thunar-volman" "zoxide" "fzf" "swww" "unzip" "p7zip")
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
    build_tools=("cmake" "make" "git")
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

### Install Required Packages ###
read -n1 -rep "${CAT} Install required packages from README.md? (y/n)" inst_pkgs
if [[ $inst_pkgs =~ ^[Yy]$ ]]; then
    required_pkgs="alacritty discord flameshot gparted google-chrome grimblast-git \
    nwg-look pamixer papirus-icon-theme pavucontrol rsync rofi sddm-git \
    thunar thunar-archive-plugin thunar-media-tags-plugin thunar-shares-plugin \
    thunar-vcs-plugin thunar-volman zoxide fzf swww unzip p7zip"
    
    yay -S --noconfirm $required_pkgs 2>&1 | tee -a $LOG || {
        print_error "Failed to install required packages. Check install.log."
        exit 1
    }
    print_success "Required packages installed successfully."
fi

### Install Hyprland Dependencies ###
read -n1 -rep "${CAT} Install Hyprland dependencies? (y/n)" inst_hypr_deps
if [[ $inst_hypr_deps =~ ^[Yy]$ ]]; then
    hypr_deps="aquamarine gdb hyprcursor hyprlang hyprutils-git hyprwayland-scanner \
    libdisplay-info libfixes libinput libliftoff libxcb libxcomposite \
    libxkbcommon libxrender meson ninja pango pixman seatd tomlplusplus \
    wayland-protocols xcb-proto xcb-util xcb-util-errors xcb-util-keysyms \
    xcb-util-wm xorg-xinput xorg-xwayland"

    yay -S --noconfirm $hypr_deps 2>&1 | tee -a $LOG || {
        print_error "Failed to install Hyprland dependencies. Check install.log."
        exit 1
    }
    print_success "Hyprland dependencies installed successfully."
fi

### Install CMake and Build Hyprland ###
read -n1 -rep "${CAT} Install and build Hyprland? (y/n)" inst_hyprland
if [[ $inst_hyprland =~ ^[Yy]$ ]]; then
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all && sudo make install
    cd ..
    rm -rf Hyprland
    print_success "Hyprland installed successfully."
fi

### Install Starship ###
read -n1 -rep "${CAT} Install Starship prompt? (y/n)" inst_starship
if [[ $inst_starship =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    print_success "Starship prompt installed successfully."
fi

### Install Prerequisites for gBar and Grimblast ###
read -n1 -rep "${CAT} Install gBar and Grimblast prerequisites? (y/n)" inst_gbar
if [[ $inst_gbar =~ ^[Yy]$ ]]; then
    prereq_pkgs="wl-clipboard mailcap gtk-layer-shell glib2 glib2-devel"
    yay -S --noconfirm $prereq_pkgs 2>&1 | tee -a $LOG || {
        print_error "Failed to install gBar prerequisites. Check install.log."
        exit 1
    }
    print_success "gBar prerequisites installed successfully."
fi

### Build and Install gBar ###
read -n1 -rep "${CAT} Build and install gBar? (y/n)" inst_gbar_build
if [[ $inst_gbar_build =~ ^[Yy]$ ]]; then
    git clone https://github.com/scorpion-26/gBar
    cd gBar
    meson setup build
    ninja -C build && sudo ninja -C build install
    cd ..
    rm -rf gBar
    print_success "gBar installed successfully."
fi

# Script completion
printf "\n${GREEN} Installation completed. Please check any logs for details.\n"
