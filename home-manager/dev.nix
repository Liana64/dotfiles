{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # General
    direnv
    pre-commit

    # Cryptography
    sops
    age

    # Kubernetes
    kubectl
    kubeconform
    helm
    talosctl

    # LSP
    nil
    nixd
    lua-language-server
    yaml-language-server
    rust-analyzer
    shellcheck
  ];

  programs.neovim.enable = true;
}
