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

  touch ~/.hushlogin

  # Install packages
  cd ./packages

  stow -t $HOME zsh
  stow -t $HOME kitty
  stow -t $HOME lazygit
fi
