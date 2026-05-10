 { pkgs, nixpkgs-unstable, ... }:
 {
  home.packages = (with pkgs; [
    autotiling-rs
    bc
    cosign
    cider-2
    moreutils
    pavucontrol
    pciutils
    protonmail-bridge
  ]) ++ (with nixpkgs-unstable; [
    claude-code
    talhelper
  ]);
 }
