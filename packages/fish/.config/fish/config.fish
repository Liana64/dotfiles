if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Config
source $HOME/.config/fish/.env
source $HOME/.config/fish/conf.d/.env

# Initializations
starship init fish | source
zoxide init fish | source
direnv hook fish | source
atuin init fish | source


# Add paths
fish_add_path /opt/sourced
fish_add_path /opt/nvim-linux64/bin
fish_add_path /opt/go/bin
fish_add_path /opt/zen
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.krew/bin
fish_add_path $HOME/go/bin
