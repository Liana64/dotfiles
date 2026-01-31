{ lib, pkgs, ... }:
{
  imports = [
    ./aliases.nix
    ./kitty.nix
    ./packages.nix
    ./starship.nix
  ];

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

  #environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs.tmux.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      sync_address = "https://sh.labs.lianas.org";
      auto_sync = true;
      sync_frequency = "5m";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  xdg.configFile."atuin/config.toml".force = lib.mkForce true;
}
