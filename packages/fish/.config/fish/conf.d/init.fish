set LN_PATH (dirname (realpath (status -f)))
set LN_VER 1.1.1

# Add ctrl-del and ctrl-]
# https://github.com/fish-shell/fish-shell/issues/1047#issuecomment-96264160
bind \e\[3\;5~ kill-word
bind \c] backward-kill-word
