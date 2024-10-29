# Hyprland Configuration Files by Kartik

## Installation

**Important**: Execute the following commands as a regular user, NOT as root!
### Yay
```
git clone git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```
### Required Packages

``` bash
yay -S alacritty discord flameshot gparted nwg-look papirus-icon-theme rofi thunar thunar-archive-plugin thunar-media-tags-plugin thunar-shares-plugin thunar-vcs-plugin thunar-volman sddm-git
```

## Install SDDM Theme


1. Clone this repository:
```sh
sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
```

2. Then edit `/etc/sddm.conf`, so that it looks like this:
```sh
echo "[Autologin]
User=john
Session=plasma

[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
```




## References
- Official Hyprland GitHub: <https://wiki.hyprland.org/Getting-Started/Installation/>
- SDDM Theme Github: <https://github.com/Keyitdev/sddm-astronaut-theme>