{ lib, pkgs, ... }:
{
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
        bindkey '^r' atuin-search
        bindkey '^[[A' atuin-up-search
        bindkey '^[OA' atuin-up-search
        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^E" edit-command-line
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        fortune
      '';

      historySubstringSearch.enable = true;
    };


  programs.tmux.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

}
