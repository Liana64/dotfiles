###
 ## Copyright (c) Liana64
 ##
 ## This source code is licensed under the MIT license found in the
 ## LICENSE file in the root directory of this source tree.
#########

function source_all
    # Check if a directory is provided
    if test (count $argv) -eq 0
        ln_log info "Usage: source_all <directory>"
        return 1
    end

    set -l dir $argv[1]

    # Check if the provided path is a directory
    if not test -d $dir
        ln_log error "'$dir' is not a directory"
        return 1
    end

    # Use find to get all regular files in the directory and its subdirectories
    for file in (find $dir -type f)
        # Check if the file is readable
        if test -r $file
            ln_log debug "Sourcing: $file"
            source $file
        else
            ln_log warning "Cannot read file '$file'. Skipping."
        end
    end
end

function ln_log --argument log_level -- $argv
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

function ln_load_tmux 
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

function ln_load_ssh 
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

function ln_weather
  if test -n "$argv"
    curl wttr.in/$argv
  else
    curl wttr.in/$LIANACFG_WEATHER_CITY
  end
end
