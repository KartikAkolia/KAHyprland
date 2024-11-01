#!/bin/bash

# Path to the Hyprland configuration file
config_file=~/.config/hypr/hyprland.conf

# Extract keybinds from the configuration file
keybinds=$(grep -oP '(?<=bind = ).*' "$config_file")
keybinds=$(echo "$keybinds" | sed 's/,\([^,]*\)$/ = \1/' | sed 's/, exec//g' | sed 's/^,//g')

# Show keybinds in Rofi and capture the selected command
selected_bind=$(echo "$keybinds" | rofi -dmenu -p "Keybinds" -theme ~/.config/rofi/themes/nord.rasi)

# Execute the selected command if not empty
if [ -n "$selected_bind" ]; then
    # Extract the command after '='
    command_to_run=$(echo "$selected_bind" | sed -n 's/.*= \(.*\)/\1/p')
    
    # Check if the command is not empty and execute it
    if [ -n "$command_to_run" ]; then
        eval "$command_to_run"
    else
        echo "No command found to execute."
    fi
fi

