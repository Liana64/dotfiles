#!/usr/bin/env bash

# This is my old install script, which is also currently broken.

install_user="liana"

if [[ $(uname) == "Darwin" ]]; then
  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew bundle install

  # Install Starship
  curl -sS https://starship.rs/install.sh | sh

  # Install Kitty Terminal
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  
  # Configure Darwin
  defaults write -g com.apple.mouse.scaling -1
  defaults write -g com.apple.trackpad.scaling -1
  defaults write -g NSWindowShouldDragOnGesture -bool true

  touch ~/.hushlogin

  # Install packages
  cd ./packages

  stow -t $HOME zsh
  stow -t $HOME kitty
  stow -t $HOME starship
  stow -t $HOME aerospace
  stow -t $HOME neovim
  stow -t $HOME lazygit
  stow -t $HOME k9s
fi

if [[ $(uname) == "Linux" ]]; then
  if [[ $(whoami) == "root" ]]; then
    echo "do not run as root"
    exit 1
  fi
  if [[ $(cat /etc/os-release) =~ "Fedora" ]]; then
    # Fundamentals
    dnf update & dnf upgrade -y
    dnf install sudo -y

    # Package Management
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    export NIX_CONFIG="experimental-features = nix-command flakes"
    #nix flake init -t github:Liana64/dotfiles

    # Source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh in shell if not using nix

    # Install Starship
    curl -sS https://starship.rs/install.sh | sh

    # Install Kitty Terminal
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    
  fi
fi
