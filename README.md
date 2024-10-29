# Hyprland Configuration Files by Kartik

## Installation

**Important**: Execute the following commands as a regular user, NOT as root!

### Yay
```bash
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

### Required Packages
```bash
yay -S alacritty discord flameshot gparted gvfs nwg-look papirus-icon-theme pavucontrol pamixer rofi sddm-git thunar thunar-archive-plugin thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin thunar-volman
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

## References
- Official Hyprland GitHub: [Hyprland Installation](https://wiki.hyprland.org/Getting-Started/Installation/)
- SDDM Theme GitHub: [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme)