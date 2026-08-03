# @desc: home-infra Taskfile toolchain (not imported; consumed by shell/infra.nix + flake/devshells.nix)
{
  pkgs,
  unstable,
}:
(with pkgs; [
  age
  ansible
  ansible-lint
  cilium-cli
  fluxcd
  gitleaks
  go-task
  helmfile
  jq
  k9s
  ktop
  kubeconform
  kubectl
  kubernetes-helm
  kustomize
  opentofu
  pre-commit
  sops
  talosctl
  yq-go
])
++ [unstable.talhelper]
