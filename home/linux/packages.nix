# @desc: Linux-only user packages (GUI + desktop)
 { pkgs, nixpkgs-unstable, ... }:
 {
  home.packages = (with pkgs; [
    autotiling-rs
    bc
    cosign
    cider-2
    moreutils
    networkmanagerapplet
    pavucontrol
    pciutils
    protonmail-bridge
  ]) ++ (with nixpkgs-unstable; [
    talhelper
  ]);
 }
