###
 ## Copyright (c) Liana64
 ##
 ## This source code is licensed under the MIT license found in the
 ## LICENSE file in the root directory of this source tree.
#########

# Variables
set -g LIANACFG_VER 1.05
set -g LIANACFG_PATH ~/.config/fish/conf.d
set -g LIANACFG_OS (uname)

source $LIANACFG_PATH/.env

# Functions

# Add !!
function !!
  set var (history | head -n 1)

  if test $var = "!!"
    fc_log info "Paradox detected. Stop that."
    return 1
  end

  if test $argv 
    if test $argv = "sudo"
      eval $argv $var
    else
      eval $var $argv
    end
  else
    eval $var
  end
end

# Add ctrl-del and ctrl-]
# https://github.com/fish-shell/fish-shell/issues/1047#issuecomment-96264160
function fish_user_key_bindings
  bind \e\[3\;5~ kill-word
  bind \c] backward-kill-word
end

function fc_load_paths
  if test "$LIANACFG_OS" = "Darwin"
    for path_appendage in $LIANACFG_PATHS_OSX
      if test -d $path_appendage
        if not contains $path_appendage $PATH
          fish_add_path $path_appendage
          fc_log debug "Added $path_appendage"
        end
      end  
    end  
  end      
end

function fc_log --argument log_level -- $argv
  if test "$LIANACFG_DEBUG" != "true" -a "$log_level" = "debug"
      return 0
  end
  set_color --bold
  switch $log_level
    case debug
      set_color --bold green
      echo -n '['(set_color normal white)'DEBUG'(set_color --bold green)']'
    case info
      set_color --bold blue
      echo -n '['(set_color normal white)'INFO'(set_color --bold blue)']'
    case warning
      set_color --bold yellow
      echo -n '['(set_color normal black)'WARNING'(set_color --bold yellow)']'
    case error
      set_color --bold red
      echo -n "["(set_color normal white)'ERROR'(set_color --bold red)']'
    case '*'
      echo "Invalid log level: $log_level"
      return 1
  end

  set_color normal
  echo " $argv[2]"
end

function fc_create_tmux_workspaces
  set quiet_mode $argv[1]
  
  set workspaces (string split ',' $LIANACFG_TMUX_WORKSPACES)
  for workspace in $workspaces
    tmux new -d -s $workspace
    fc_log debug "Created tmux workspace: $workspace"
  end
  if test "$quiet_mode" != "q"
    fc_log info "Finished creating workspaces"
  end
end

function fc_add_ssh_keys
  set agents_dir $LIANACFG_SSH_AGENTS_DIR
  fc_log debug "Adding keys from $LIANACFG_SSH_AGENTS_DIR"

  if not test -d $agents_dir
    fc_log error "Directory $agents_dir does not exist"
    return 1
  end

  for key in (find -L $LIANACFG_SSH_AGENTS_DIR -type f)
    eval ssh-add $key
    if test $status -eq 0
      fc_log debug "Added SSH key: $key"
    else
      fc_log error "Failed to add SSH key: $key"
    end
  end
end

function fc_getweather
  if test -n "$argv"
    curl wttr.in/$argv
  else
    curl wttr.in/$LIANACFG_WEATHER_CITY
  end
end

# Main
fc_load_paths

# Script Shortcuts
alias editcfg='$EDITOR $LIANACFG_PATH/shortcuts.fish && reloadcfg'
alias editenv='$EDITOR $LIANACFG_PATH/.env && reloadenv'
alias helpcfg='cat $LIANACFG_PATH/shortcuts.fish | less'
alias lianacfg='cd $LIANACFG_PATH'
alias reloadenv='source $LIANACFG_PATH/.env && fc_log info "Updated environment"'
alias reloadcfg='source $LIANACFG_PATH/shortcuts.fish && fc_log info "Updated config"'
alias versioncfg='fc_log info v$LIANACFG_VER'

# Personal Shortcuts
alias weather='fc_getweather'
alias news='echo "" && curl -s https://brutalist.report/summary | sed -rn "s@(^.*<li>)(.*)(</li>)@\2\n@p" | sed "s|<strong>|• |g; s|</strong>||g"'

# Replacements
alias cat='batcat'
#alias cd='z'
alias nfetch='echo && echo && neofetch'
alias ls='eza'
alias grep='rg'

# Main Shortcuts
alias c='clear'
alias cc='cd && clear'
alias e='exit'
alias exp='export'
alias f='fabric'
alias g='grep'
alias hex='openssl rand -hex'
alias i='whoami'
alias l='eza -la'
alias mktmp='cd "$(mktemp -d)"'
alias n='$EDITOR'
alias now='date +"%T"'
alias r='sudo su -'
alias rp='realpath'
alias s='sudo'

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
alias ssh-add-all='fc_add_ssh_keys'

# Ansible Shortcuts
alias ans='cd /etc/ansible'
alias ova='eval "$(read -s VAULTKEY && export VAULTKEY)"'
alias v='ansible-vault'

# Kubernetes Shortcuts
alias k='kubectl'
alias kc='kubectl config current-context'
alias kcls='kubectl config get-contexts'
alias kcu='kubectl config use-context'

alias kga='kubectl get all -A'
alias kak='kubectl apply -k'
alias kaf='kubectl apply -f'
alias kdk='kubectl delete -k'
alias kdf='kubectl delete -f'

# Docker Shortcuts
alias d='docker'
alias dc='docker compose'
alias dn='docker network'
alias dv='docker volume'

# Tmux Shortcuts
alias t='tmux a -t'
alias tks='tmux kill-server'
alias tls='tmux ls'
alias tn='tmux new'
alias tns='tmux new -s'
alias tws='fc_create_tmux_workspaces'
