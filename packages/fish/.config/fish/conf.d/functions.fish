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
  if test "$LN_DEBUG" != "true" -a "$log_level" = "debug"
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
  
  set workspaces (string split ',' $LN_TMUX)
  for workspace in $workspaces
    tmux new -d -s $workspace
    ln_log debug "Created tmux workspace: $workspace"
  end
  if test "$quiet_mode" != "q"
    ln_log info "Finished creating workspaces"
  end
end

function ln_load_ssh 
  set agents_dir $LN_SSH_AGENTS
  ln_log debug "Adding keys from $LN_SSH_AGENTS"

  if not test -d $agents_dir
    ln_log error "Directory $agents_dir does not exist"
    return 1
  end

  for key in (find -L $LN_SSH_AGENTS -type f)
    eval ssh-add $key
    if test $status -eq 0
      ln_log debug "Added SSH key: $key"
    else
      ln_log error "Failed to add SSH key: $key"
    end
  end
end

function ln_weather
  if test -n "$argv"
    curl wttr.in/$argv
  else
    curl wttr.in/$LN_CITY
  end
end

function kencode
  if test -n "$argv"
    echo -n "$argv" | base64 -w 0
  else if not test -t 0
    cat | base64 -w 0
  else
    echo "No secret provided. Please specify a secret or place it into the pipe, e.g.: ls | kencode"
  end
end

function kdecode 
  if test -n "$argv"
    echo -n "$argv" | base64 -d
  else if not test -t 0
    cat | base64 -d
  else
    echo "No secret provided. Please specify a secret or place it into the pipe, e.g.: ls | kdecode"
  end
end
