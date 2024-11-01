# Hyprland Configuration Files by Kartik

![Screenshot](https://github.com/KartikAkolia/KAHyprland/blob/main/desktop.png)

## Installation

**Important**: Note show_keybinds.sh needs to be executable and in the home directory.
**Important**: You don't have to have modify the hyprland.conf!!!

```bash
chmod +x show_keybinds.sh
```

### Yay
```bash
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

### Install Hyprland Dependencies
```bash
yay -S aquamarine gdb hyprcursor hyprlang hyprutils-git hyprwayland-scanner libdisplay-info libfixes libinput libliftoff libxcb libxcomposite libxkbcommon libxrender meson ninja pango pixman seatd tomlplusplus wayland-protocols xcb-proto xcb-util xcb-util-errors xcb-util-keysyms xcb-util-wm xorg-xinput xorg-xwayland
```

### CMake Install 
```
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
make all && sudo make install
```

### Required Packages
```bash
yay -S alacritty discord flameshot gparted google-chrome grimblast-git nwg-look pamixer papirus-icon-theme pavucontrol rsync rofi sddm-git thunar thunar-archive-plugin thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin thunar-volman zoxide fzf swww
```

### Install Starship
```bash
curl -sS https://starship.rs/install.sh | sh
```

## Add the following to the end of `~/.bashrc`
```bash
eval "$(starship init bash)"
eval "$(zoxide init bash)"
```

## Prerequisites Packages Install Before gBar and Grimblast
```bash
yay -S wl-clipboard mailcap gtk-layer-shell glib2 glib2-devel
```

## Build and Install of gBar

1. Clone gBar
    ```sh
    git clone https://github.com/scorpion-26/gBar
    ```
2. Configure with meson
    *All optional dependencies enabled*
    ```bash
    meson setup build
    ```
3. Build and install
    ```bash
    ninja -C build && sudo ninja -C build install
    ```

### GParted Extra Dependencies
```bash
yay -S btrfs-progs exfatprogs e2fsprogs f2fs-tools dosfstools mtools jfsutils util-linux nilfs-utils ntfs-3g udftools xfsprogs xfsdump lvm2
```

## Install SDDM Theme

1. Clone this repository:
    ```bash
    sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
    sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
    ```

2. Then edit `/etc/sddm.conf`, so that it looks like this:
    ```bash
    echo "[Autologin]
    User=kartik
    Session=dwm

    [Theme]
    Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
    ```

## Final Copy All Configs

```bash
rsync -avP * ~/.config/
rm ~/.config/LICENSE
rm ~/.config/README.md
```

## References
- ChrisTitusTech:[Hyprland Titus] (https://github.com/ChrisTitusTech/hyprland-titus)
- ChrisTitusTech MyBash:[ChrisTitusTech MyBash] (https://github.com/ChrisTitusTech/mybash) 
- Official Hyprland GitHub: [Hyprland Installation](https://wiki.hyprland.org/Getting-Started/Installation/)
- SDDM Theme GitHub: [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme)
- gBar:[gBar](https://github.com/scorpion-26/gBar)


