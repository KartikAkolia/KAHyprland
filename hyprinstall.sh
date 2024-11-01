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

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n$YELLOW Some commands require you to enter your password in order to execute.
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review the contents of this script.\n"

sleep 3

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}

### Install Yay ###
if ! command -v yay &> /dev/null; then
    printf "$YELLOW Installing Yay...\n"
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
    print_success "Yay installed successfully."
fi

### Install Required Packages ###
read -n1 -rep "${CAT} Would you like to install the required packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye!\n"
    exit 1
fi

if [[ $inst =~ ^[Yy]$ ]]; then
    # Define packages based on the README.md structure
    git_pkgs="grimblast-git hyprpicker-git aylurs-gtk-shell"
    hypr_pkgs="hyprland wl-clipboard wf-recorder rofi sddm wlogout dunst swww alacritty hyprcursor hyprlang noto-fonts noto-fonts-emoji"
    app_pkgs="nwg-look qt5ct btop jq gvfs ffmpegthumbs mpv playerctl pamixer noise-suppression-for-voice"
    app_pkgs2="mate-polkit ffmpeg neovim viewnior pavucontrol thunar ffmpegthumbnailer tumbler thunar-archive-plugin xdg-user-dirs"
    theme_pkgs="nordic-theme papirus-icon-theme starship"

    if ! yay -S --noconfirm $git_pkgs $hypr_pkgs $app_pkgs $app_pkgs2 $theme_pkgs 2>&1 | tee -a $LOG; then
        print_error "Failed to install additional packages - please check the install.log\n"
        exit 1
    fi
    xdg-user-dirs-update
    print_success "All necessary packages installed successfully."
else
    echo
    print_error "Packages not installed - please check the install.log."
    sleep 1
fi

### Install Hyprland Dependencies ###
printf "${CAT} Installing Hyprland dependencies...\n"
yay -S --noconfirm aquamarine gdb hyprlang hyprutils-git hyprwayland-scanner libdisplay-info libfixes libinput libliftoff libxcb libxcomposite libxkbcommon libxrender meson ninja pango pixman seatd tomlplusplus wayland-protocols xcb-proto xcb-util xcb-util-errors xcb-util-keysyms xcb-util-wm xorg-xinput xorg-xwayland 2>&1 | tee -a $LOG

### Install CMake ###
printf "${CAT} Installing CMake...\n"
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
make all && sudo make install
cd ..
rm -rf Hyprland

### Install Starship ###
printf "${CAT} Installing Starship...\n"
curl -sS https://starship.rs/install.sh | sh

# Add Starship initialization to .bashrc
{
    echo "eval \"\$(starship init bash)\""
    echo "eval \"\$(zoxide init bash)\""
} >> ~/.bashrc

### Install Fonts ###
FONT_DIR="$HOME/.local/share/fonts"
FONT_ZIP="$FONT_DIR/Meslo.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"

if fc-list | grep -qi "Meslo"; then
    echo "Meslo Nerd-fonts are already installed."
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
    fc-cache -fv
    print_success "Meslo Nerd-fonts installed successfully."
fi

### Build and Install gBar ###
read -n1 -rep "${CAT} Would you like to build and install gBar? (y/n)" gbar_inst
if [[ $gbar_inst =~ ^[Yy]$ ]]; then
    printf " Cloning gBar repository...\n"
    git clone https://github.com/scorpion-26/gBar
    cd gBar
    meson setup build
    ninja -C build && sudo ninja -C build install
    cd ..
    rm -rf gBar
    print_success "gBar installed successfully."
fi

### Install GParted Extra Dependencies ###
printf "${CAT} Installing GParted extra dependencies...\n"
yay -S --noconfirm btrfs-progs exfatprogs e2fsprogs f2fs-tools dosfstools mtools jfsutils util-linux nilfs-utils ntfs-3g udftools xfsprogs xfsdump lvm2 2>&1 | tee -a $LOG

### Install SDDM Theme ###
printf "${CAT} Installing SDDM theme...\n"
sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
{
    echo "[Autologin]"
    echo "User=$(whoami)"
    echo "Session=hyprland"
} | sudo tee -a /etc/sddm.conf

printf "Enabling SDDM service...\n"
sudo systemctl enable sddm

### Copy Config Files ###
read -n1 -rep "${CAT} Would you like to copy config files? (y/n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
    printf " Copying config files...\n"
    cp -r dotconfig/dunst ~/.config/ 2>&1 | tee -a $LOG
    cp -r dotconfig/hypr ~/.config/ 2>&1 | tee -a $LOG
    cp -r dotconfig/kitty ~/.config/ 2>&1 | tee -a $LOG
    cp -r dotconfig/pipewire ~/.config/ 2>&1 | tee -a $LOG
    cp -r dotconfig/rofi ~/.config/ 2>&1 | tee -a $LOG
    cp -r dotconfig/wlogout ~/.config/ 2>&1 | tee -a $LOG

    # Set some files as executable 
    chmod +x ~/.config/hypr/xdg-portal-hyprland
    print_success "Config files copied successfully."
fi

### Enable SDDM Autologin ###
read -n1 -rep "${CAT} Would you like to enable SDDM autologin? (y/n)" SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
    LOC="/etc/sddm.conf"
    echo -e "The following has been added to $LOC.\n"
    {
        echo "[Autologin]"
        echo "User=$(whoami)"
        echo "Session=hyprland"
    } | sudo tee -a $LOC
    print_success "SDDM autologin enabled."
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Installing Bluetooth Packages...\n"
    blue_pkgs="bluez bluez-utils blueman"
    if ! yay -S --noconfirm $blue_pkgs 2>&1 | tee -a $LOG; then
        print_error "Failed to install Bluetooth packages - please check the install.log"
    fi
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
else
    printf "${YELLOW} No Bluetooth packages installed..\n"
fi

### Finish ###
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
        print_error "Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi
