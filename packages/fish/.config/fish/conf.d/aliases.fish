#Script Shortcuts
alias editcfg='$EDITOR $DF_PATH' 
alias editenv='$EDITOR $LN_PATH/.env'
alias lianacfg='cd $LN_PATH'
alias reloadcfg='source_all $LN_PATH && ln_log info "Updated config"'
alias versioncfg='ln_log info v$LN_VER'

# Personal Shortcuts
alias weather='ln_weather'
alias news='echo "" && curl -s https://brutalist.report/summary | sed -rn "s@(^.*<li>)(.*)(</li>)@\2\n@p" | sed "s|<strong>|• |g; s|</strong>||g"'
alias ifc='echo "" && curl -s https://ifconfig.me && echo ""'
alias wip='./scripts/wip.sh'
alias deploy='./scripts/deploy.sh'

# Tools and CLIs 
alias cat='bat'
alias f='fabric'
alias grep='rg'
alias l='eza -la'
alias ls='eza'
alias nfetch='echo && echo && neofetch'

# Main Shortcuts
alias c='clear'
alias cc='cd && clear'
alias e='exit'
alias g='grep'
alias hex='openssl rand -hex'
alias mktmp='cd "$(mktemp -d)"'
alias n='$EDITOR'
alias now='date +"%T"'
alias r='sudo su -'
alias rp='realpath'
alias s='sudo'
alias wh='which'
alias zy='zypper'

## Debian Shortcuts
alias u='sudo apt update'
alias uu='sudo apt update && sudo apt upgrade -y'

# Git Shortcuts
alias pull='git pull'
alias pullh='git pull --reset hard'

# SSH Shortcuts
alias ssha='eval $(ssh-agent -c)'
alias ssharm='ssh-agent -k'
alias sshcfg='$EDITOR ~/.ssh/config'
alias sshls='ssh-add -L'
alias ssh-add-all='ln_load_ssh'

# Ansible Shortcuts
alias ans='cd /etc/ansible'
alias ova='read -s VAULTKEY && export VAULTKEY'

# Kubernetes Shortcuts
alias k='kubectl'
alias kc='kubectl config current-context'
alias kcls='kubectl config get-contexts'
alias kcu='kubectl config use-context'
alias kga='kubectl get all -A'
alias tc='talosctl'

# Docker Shortcuts
alias d='docker'
alias dc='docker compose'
alias dn='docker network'
alias dv='docker volume'
alias dpull='docker compose pull && docker compose up -d --remove-orphans'

# Tmux Shortcuts
alias t='tmux'
alias tt='tmux a -t'
alias tks='tmux kill-server'
alias tws='ln_load_tmux'
