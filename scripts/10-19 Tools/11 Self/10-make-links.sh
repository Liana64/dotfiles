#!/bin/bash

# Variables
DOTFILES_DIR="$(realpath .)"
BASE_DIR="$DOTFILES_DIR/base"
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

        # Create the symlink for the folder
        ln -s "$source" "$destination"
        echo "Created symlink for $folder"
    else
        echo "Warning: Source folder $source does not exist. Skipping."
    fi

    # Now check if there's a corresponding folder inside the "base" directory
    base_folder="$BASE_DIR/$folder"
    if [ -d "$base_folder" ]; then
        echo "Found corresponding folder inside 'base' for $folder. Symlinking files individually."

        # Iterate over files inside the "base" subfolder and symlink them individually
        for file in "$base_folder"/*; do
            base_file_name=$(basename "$file")
            target="$destination/$base_file_name"

            # Create destination folder if it doesn't exist
            if [ ! -d "$destination" ]; then
                mkdir -p "$destination"
            fi

            # Remove any existing symlink or file in the target location
            if [ -L "$target" ]; then
                rm "$target"
            elif [ -e "$target" ]; then
                mv "$target" "$target.bak"
            fi

            # Create the symlink for the file
            ln -s "$file" "$target"
            echo "Created symlink for $base_file_name inside $folder from 'base'"
        done
    fi
done

echo "Symlinking complete!"
