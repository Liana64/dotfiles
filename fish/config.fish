if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
zoxide init fish | source

set PATH $PATH /home/liana/.local/bin
set PATH $PATH /opt/nvim-linux64/bin
set PATH $PATH /opt/go/bin
set PATH $PATH /home/liana/go/bin
