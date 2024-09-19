if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Initializations
starship init fish | source
zoxide init fish | source
direnv hook fish | source

# Config
source $HOME/.config/fish/conf.d/.env

# Add paths
fish_add_path /opt/sourced
fish_add_path /opt/nvim-linux64/bin
fish_add_path /opt/go/bin
fish_add_path /opt/zen
fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
