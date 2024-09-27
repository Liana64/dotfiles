###
 ## Copyright (c) Liana64
 ##
 ## This source code is licensed under the MIT license found in the
 ## LICENSE file in the root directory of this source tree.
#########

set LN_PATH (dirname (realpath (status -f)))
set LN_VER 1.1.1

# Add ctrl-del and ctrl-]
# https://github.com/fish-shell/fish-shell/issues/1047#issuecomment-96264160
bind \e\[3\;5~ kill-word
bind \c] backward-kill-word
