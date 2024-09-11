if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Initialize CLI tools
starship init fish | source
zoxide init fish | source

# Set universals
set -U EDITOR nvim

# Add paths
fish_add_path /opt/sourced
fish_add_path /opt/nvim-linux64/bin
fish_add_path /opt/go/bin
fish_add_path /opt/zen
fish_add_path /home/liana/.local/bin
fish_add_path /home/liana/go/bin
