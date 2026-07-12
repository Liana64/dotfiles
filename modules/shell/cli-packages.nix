# @desc: Cross-platform user CLI packages
{...}: {
  flake.modules.homeManager.cliPackages = {pkgs, ...}: {
    home.packages = with pkgs; [
      age
      # ansible (home-infra devshell)
      asciinema
      bat
      btop
      # cilium-cli (home-infra devshell)
      delta
      dig
      distrobox
      duf
      dust
      eza
      fastfetch
      ffmpeg
      # fluxcd (home-infra devshell)
      fortune
      fzf
      go-task
      imagemagick
      just
      jq
      # ktop (home-infra devshell)
      # kubeconform (home-infra devshell)
      kubectl
      # kubernetes-helm (home-infra devshell)
      # kustomize (home-infra devshell)
      lazygit
      lua-language-server
      marksman
      nil
      nixd
      nix-tree
      pre-commit
      ripgrep
      ripgrep-all
      rustscan
      shellcheck
      sops
      # talosctl (home-infra devshell)
      tealdeer
      usbutils
      watchexec
      yaml-language-server
      yazi
      yq-go
    ];
  };
}
