{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./nvim.nix
  ];

  # TODO: Fix broken k9s plugins
  # TODO: Figure out a way to remember to use k9s plugins
  programs.k9s = {
    enable = true;
    settings = import ./k9s/settings.nix;
    aliases = import ./k9s/aliases.nix;
    skins = import ./k9s/skins.nix;
    plugins = import ./k9s/plugins.nix;
  };

  home.packages = with pkgs; [
    go-task
    pre-commit
    lazygit
    ansible
    dig
    watchexec
    #hyperfine
    #tokei
    #lsof
    #gparted
    #parted
    todoist-electron

    # Cryptography
    sops
    age

    # Kubernetes
    kubectl
    kubeconform
    kubernetes-helm
    talosctl
    talhelper
    fluxcd
    cilium-cli

    # LSP
    nil
    nixd
    lua-language-server
    yaml-language-server
    rust-analyzer
    marksman
    shellcheck
    
  ];

  #programs.direnv = {
  #  enable = true;
  #  enableZshIntegration = true;
  #  nix-direnv.enable = true;
  #};
}
