{ pkgs, ... }:
{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  }

  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";

  programs.tmux.enable = true;
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    bat
    duf
    delta
    dust
    fd
    btop
    fastfetch
    zoxide
    fortune
    ripgrep
    ripgrep-all
    bat
    jq
    yq
    fd
  ];
}
