#!/bin/bash

packages=("aerospace" "alacritty" "fish" "k9s" "neovim" "s" "starship" "tmux")

if ! command -v stow >/dev/null 2>&1; then
    echo "Error: GNU Stow is not installed. Please install it and try again."
    exit 1
fi

ask_user() {
    local question="$1"
    while true; do
        read -p "$question (Y/n): " yn
        case $yn in
            [Yy]* ) 
                return 0
                ;;
            [Nn]* ) 
                return 1
                ;;
            * ) 
                echo "Please answer Y or n."
                ;;
        esac
    done
}

for package in "${packages[@]}"; do
    if ask_user "Uninstall dotfiles for $package?"; then
        stow -t $HOME -D "$package"
        echo "Uninstalled $package"
    else
        echo "Skipped $package"
    fi
done

echo "Finished"
