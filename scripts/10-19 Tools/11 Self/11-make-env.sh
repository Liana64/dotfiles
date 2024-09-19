#!/bin/bash

# Function to prompt Yes/No questions
function yes_no_prompt() {
    local prompt="$1"
    local response
    while true; do
        read -r -p "$prompt (Y/n): " response
        case "$response" in
            [yY][eE][sS]|[yY]|'') return 0 ;;
            [nN][oO]|[nN]) return 1 ;;
            *) echo "Please enter Y or n." ;;
        esac
    done
}

# Function to sanitize city input
function sanitize_city() {
    echo "$1" | sed 's/[^a-zA-Z ]//g' | xargs
}

# Function to validate folder paths
function validate_folder() {
    if [[ "$1" == /* || "$1" == \$HOME* ]]; then
        echo "$1"
    else
        echo ""
    fi
}

# Function to sanitize tmux workspace input (comma separated list)
function sanitize_tmux_workspaces() {
    echo "$1" | sed 's/[^a-zA-Z0-9_,]//g' | xargs
}

# Prompting the user for input

# LN_DEBUG
if yes_no_prompt "Enable debug mode?"; then
    LN_DEBUG="true"
else
    LN_DEBUG="false"
fi

# LN_CITY
while true; do
    read -r -p "What city would you like weather reports for? " city
    LN_CITY=$(sanitize_city "$city")
    if [[ -n "$LN_CITY" ]]; then
        break
    else
        echo "Please enter a valid city name."
    fi
done

# LN_SSH_AGENTS
while true; do
    read -r -p "What folder would you like to search for SSH agents in? " folder
    LN_SSH_AGENTS=$(validate_folder "$folder")
    if [[ -n "$LN_SSH_AGENTS" ]]; then
        break
    else
        echo "Please enter a valid folder path (absolute path or \$HOME)."
    fi
done

# LN_TMUX
while true; do
    read -r -p "What tmux workspaces would you like to setup (separated by commas)? " workspaces
    LN_TMUX=$(sanitize_tmux_workspaces "$workspaces")
    if [[ -n "$LN_TMUX" ]]; then
        break
    else
        echo "Please enter valid tmux workspaces (comma-separated)."
    fi
done

# Output for the user to save as a .env file
echo ""
echo "# Save the following in your .env file:"
echo "set LN_DEBUG $LN_DEBUG"
echo "set LN_CITY \"$LN_CITY\""
echo "set LN_SSH_AGENTS \"$LN_SSH_AGENTS\""
echo "set LN_TMUX \"$LN_TMUX\""

