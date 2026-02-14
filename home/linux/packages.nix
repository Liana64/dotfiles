 { pkgs, ... }:
 {
  home.packages = with pkgs; [
    bc
    cider-2
    moreutils
    pavucontrol
    pciutils
    protonmail-bridge
    xdg-desktop-portal
    todoist-electron
    autotiling-rs
  ];
 }
