eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"

bindkey '^r' atuin-search
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

fortune

source ~/.zsh_includes/aliases.zsh
source ~/.zsh_includes/tmux.zsh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export TERM=xterm-256color
