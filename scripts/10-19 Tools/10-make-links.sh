#!/bin/bash

# Variables
DOTFILES_DIR="$(realpath .)"
CONFIG_DIR="$HOME/.config"
folders=(fish nvim k9s alacritty s starship tmux)

# Functions
for folder in "${folders[@]}"; do
    source="$DOTFILES_DIR/$folder"
    destination="$CONFIG_DIR/$folder"

    # Check if the source folder exists
    if [ -d "$source" ]; then
        # Remove existing destination if it's a symlink
        if [ -L "$destination" ]; then
            rm "$destination"
        # Backup existing destination if it's a regular directory
        elif [ -d "$destination" ]; then
            mv "$destination" "${destination}.bak"
        fi

        # Create the symlink
        ln -s "$source" "$destination"
        echo "Created symlink for $folder"
    else
        echo "Warning: Source folder $source does not exist. Skipping."
    fi
done

echo "Symlinking complete!"
