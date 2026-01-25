{ pkgs, ... }:
{
  home.packages = with pkgs; [
      bat
      duf
      delta
      dust
      fd
      btop
      xh
      fastfetch
      zoxide
      fortune
      ripgrep
      ripgrep-all
      tealdeer
      bat
      jq
      yq
      fd
      eza
      procs
      rustscan
      hexyl
    ];
}
