# @desc: Zsh: history, completion, autosuggestion
{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = false;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    # Edit command in nvim with ctrl-e
    initContent = ''
      [[ -t 0 ]] && stty -ixon
      bindkey '^r' atuin-search
      bindkey '^[[A' atuin-up-search
      bindkey '^[OA' atuin-up-search
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^E" edit-command-line
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      [[ -s /run/audit-tripwires ]] && cat /run/audit-tripwires
      if (( RANDOM % 2 )); then fortune; else dice; fi
    '';

    historySubstringSearch.enable = true;
  };

  programs.direnv.enable = true;
  programs.tmux.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
