###
 ## Copyright (c) Liana64
 ##
 ## This source code is licensed under the MIT license found in the
 ## LICENSE file in the root directory of this source tree.
#########

# Add !!
function !!
  set var (history | head -n 1)

  if test $var = "!!"
    ln_log warning "Paradox detected. Stop that."
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
function ln_load
  bind \e\[3\;5~ kill-word
  bind \c] backward-kill-word
end

# Add Johnny Decimal index
function index
    if test -d $argv[1]
        tree $argv[1] -L 3 | rg -w '[0-9][0-9].[0-9][0-9]'
    else
        ln_log warning "Directory $argv[1] does not exist."
    end
end

