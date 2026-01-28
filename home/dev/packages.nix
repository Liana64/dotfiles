{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # General
    go-task
    pre-commit
    lazygit
    hyperfine
    tokei

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
}
