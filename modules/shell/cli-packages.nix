# @desc: Cross-platform user CLI packages
{...}: {
  flake.modules.homeManager.cliPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      age
      asciinema
      bat
      btop
      delta
      dig
      distrobox
      duf
      dust
      eza
      fastfetch
      fd
      ffmpeg
      fortune
      fzf
      go-task
      imagemagick
      just
      jq
      kubectl
      lazygit
      lua-language-server
      marksman
      nixd
      nix-tree
      pre-commit
      ripgrep
      ripgrep-all
      rustscan
      shellcheck
      sops
      tealdeer
      usbutils
      watchexec
      yaml-language-server
      yazi
      yq-go
    ];
  };
}
